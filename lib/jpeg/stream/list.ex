defmodule JPEG.Stream.CharList do
  @moduledoc """
    This module provides lazy fetching of items from a stream.
    Blatantly inspired by https://github.com/tallakt/stream_split/blob/master/lib/stream_split.ex
  """

  @doc """
    Fetch n items from an enumerable into a {list, tail} tuple,
    where the tail is the remainder of the stream.
  """
  @spec fetch(Enumerable.t, pos_integer) :: {List.t, Enumerable.t}
  def fetch(stream, count) when count > 0 do
    initial_acc = {:cont, {count, []}}
    result = Enumerable.reduce(stream, initial_acc, &reduce/2)

    case result do
      {:done,       {_, list}       } -> {reverse(list), []                     }
      {:suspended,  {_, list}, cont } -> {reverse(list), createTailStream(cont) }
    end
  end

  @doc """
    Fetching 0 items from the enumerable, returns an empty list and the enumerable.
  """
  def fetch(stream, 0), do: {[], stream}

  # When reduce function receives a :tail atom,
  # it should suspend the stream
  # and return the item it got.
  defp reduce(item, :tail) do
    {:suspend, item}
  end

  # When reduce receives a count arg greater than 1
  defp reduce(item, {count, list}) when count > 1 do
    {:cont, {count - 1, [item | list]}}
  end

  # When reduce receives an accumulator with empty count,
  # the items is the last one to be added to the list,
  # and the stream should be suspended.
  defp reduce(item, {_count, list}) do
    {:suspend, {0, [item | list]}}
  end

  # Create a new Stream, that continues from the position of the last fetch.
  defp createTailStream(cont_fun) do
    # The start function
    fn_start = fn -> {:suspended, nil, cont_fun} end

    fn_next = fn _prev_acc = {_state, _item, next} ->
      next_result = next.({:cont, :tail})
      case next_result do
        tail = {:suspended, item, _cont_fun} -> {[item], tail}
        {:done, acc} -> {:halt, acc}
      end
    end

    # The after function halts the stream, if not already halted.
    fn_after = fn
      {:suspended, _item, next}  -> next.({:halt, nil})
      _ -> nil
    end

    Stream.resource(fn_start, fn_next, fn_after)
  end

  # Reverse a give list.
  # L.E.: just use :lists.reverse()
  defp reverse(list), do: :lists.reverse(list)

  @doc """
    Fetch count items into a list, and return a tuple
    made of the list, and a stream that provides the list again followed by the tail
  """
  @spec peek(Enumerable.t, pos_integer) :: {List.t, Enumerable.t}
  def peek(stream, count) do
    {list, tail} = fetch(stream, count)
    {list, Stream.concat(list, tail)}
  end
end
