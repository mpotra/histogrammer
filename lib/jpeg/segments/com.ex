defmodule JPEG.Segment.COM do
  alias __MODULE__

  alias JPEG.Header
  #import JPEG.Stream.Binary, only: [fetch: 2]
  import JPEG.Util

  defstruct identifier: "COM",
            length: 0,
            data: nil

  def match?(bytes) do
    case match(bytes) do
      {:ok} -> true
      {:error, _} -> false
    end
  end
  def match(<<0xFF, 0xFE>>), do: {:ok}
  def match(_), do: {:error, "Invalid COM marker"}

  def parse(header) do
    {length, tail} = JPEG.Stream.Binary.fetch(header.stream, 2)
    len = toUInt16(length)
    {data, remainder} = JPEG.Stream.Binary.fetch(tail, len - 2)
    IO.puts "Comment segment:"
    IO.inspect data
    comment = %COM{length: len, data: data}
    %Header{header | stream: remainder, comments: [comment | header.comments]}
  end
end
