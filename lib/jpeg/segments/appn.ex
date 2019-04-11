defmodule JPEG.Segment.APPn do
  alias __MODULE__
  alias JPEG.Header
  import JPEG.Stream.Binary, only: [fetch: 2]
  import JPEG.Util

  defstruct identifier: "APPn",
            index: 0,
            length: 0,
            data: nil

  def match?(bytes) do
    case match(bytes) do
      {:ok} -> true
      {:error, _} -> false
    end
  end
  def match(<<0xFF, b>>) when is_integer(b) and b >= 0xE1 and b <= 0xEF, do: {:ok}
  def match(_), do: {:error, "Invalid APPn marker"}

  def parse(header) do
    {length, tail} = fetch(header.stream, 2)
    len = toUInt16(length)
    {info, remainder} = fetch(tail, len - 2)
    segment = %APPn{length: len, data: info}
    %Header{header | stream: remainder, segments: [segment | header.segments]}
  end
end
