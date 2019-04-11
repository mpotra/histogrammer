defmodule JPEG.Segment.SOF do
  @moduledoc """
    SOF (Start Of Frame)
  """

  alias __MODULE__
  alias JPEG.Header
  #import JPEG.Stream.Binary, only: [fetch: 2]
  import JPEG.Util

  defstruct identifier: "SOF",
            length: 0,
            extended: false,
            progressive: false,
            baseline: false,
            precision: 0,
            scanLines: 0,
            samplesPerLine: 0,
            componentsOrder: []

  def parse(header, type \\ :baseline) do
    {length, tail} = JPEG.Stream.Binary.fetch(header.stream, 2)
    frameLength = toUInt16(length) - 2
    IO.puts "SOF Segment length: #{frameLength}"
    {_data, tail} = JPEG.Stream.Binary.fetch(tail, frameLength)

    sof = %SOF{length: frameLength}
    sof = case type do
      :progressive -> %SOF{sof | progressive: true}
      :extended -> %SOF{sof | extended: true}
      _ -> %SOF{sof | baseline: true}
    end

    %Header{header | stream: tail, frames: [sof | header.frames]}
  end
end
