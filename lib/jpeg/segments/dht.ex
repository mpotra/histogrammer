defmodule JPEG.Segment.DHT do
  @moduledoc """
    DHT (Define Huffman Table(s))
  """

  alias __MODULE__
  alias JPEG.Header
  #import JPEG.Stream.Binary, only: [fetch: 2]
  import JPEG.Util

  defstruct identifier: "DHT",
            length: 0,
            table: nil

  def parse(header) do
    {length, tail} = JPEG.Stream.Binary.fetch(header.stream, 2)
    huffmanLength = toUInt16(length) - 2
    IO.puts "DHT Segment length: #{huffmanLength}"
    {_data, tail} = JPEG.Stream.Binary.fetch(tail, huffmanLength)

    dht = %DHT{length: huffmanLength}

    %Header{header | stream: tail, segments: [dht | header.segments]}
  end
end
