defmodule JPEG.Segment.DQT do
  @moduledoc """
    DQT (Define Quantization Tables)
  """

  alias __MODULE__
  alias JPEG.Header
  #import JPEG.Stream.Binary, only: [fetch: 2]
  import JPEG.Util

  defstruct identifier: "DQT",
            length: 0,
            table: nil

  def match?(bytes) do
    case match(bytes) do
      {:ok} -> true
      {:error, _} -> false
    end
  end
  def match(<<0xFF, 0xDB>>), do: {:ok}
  def match(_), do: {:error, "Invalid DQT marker"}

  def parse(header) do
    {length, tail} = JPEG.Stream.Binary.fetch(header.stream, 2)
    quantizationTablesLength = toUInt16(length) - 2
    IO.puts "DQT Segment length: #{quantizationTablesLength}"
    {_data, tail} = JPEG.Stream.Binary.fetch(tail, quantizationTablesLength)

    dqt = %DQT{length: quantizationTablesLength}

    %Header{header | stream: tail, segments: [dqt | header.segments]}
  end
end
