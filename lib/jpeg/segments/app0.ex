defmodule JPEG.Segment.APP0.JFXX do
  def match?(bytes) do
    case match(bytes) do
      {:ok} -> true
      {:error, _} -> false
    end
  end
  def match(<<"J", "F", "X", "X", 0>>), do: {:ok}
  def match(_), do: {:error, "Invalid JFXX marker"}

  def parse(_header, _length) do
    {:error, "JFXX segment processing not implemented"}
  end
end

defmodule JPEG.Segment.APP0.JFIF do
  alias __MODULE__
  alias JPEG.Header
  #import JPEG.Stream.Binary, only: [fetch: 2]

  defstruct identifier: "JFIF",
            length: 0,
            major: 0,
            minor: 0,
            units: 0,
            xDensity: 0,
            yDensity: 0,
            thumbWidth: 0,
            thumbHeight: 0,
            thumbData: nil

  def match?(bytes) do
    case match(bytes) do
      {:ok} -> true
      {:error, _} -> false
    end
  end
  def match(<<"J", "F", "I", "F", 0>>), do: {:ok}
  def match(_), do: {:error, "Invalid JFIF marker"}

  def parse(header, length) do
    {segment, tail} = JPEG.Stream.Binary.fetch(header.stream, length)

    <<
      major :: size(8),
      minor :: size(8),
      units :: size(8),
      xDensity :: size(16),
      yDensity :: size(16),
      thumbWidth :: size(8),
      thumbHeight :: size(8),
      thumbData :: binary
    >> = segment

    jfif = %JFIF{
      length: length,
      major: major,
      minor: minor,
      units: units,
      xDensity: xDensity,
      yDensity: yDensity,
      thumbWidth: thumbWidth,
      thumbHeight: thumbHeight,
      thumbData: thumbData
    }

    %Header{header | stream: tail, segments: [jfif | header.segments]}
  end
end


defmodule JPEG.Segment.APP0 do
  alias JPEG.Segment.APP0.{JFIF, JFXX}

  alias JPEG.Header
  import JPEG.Stream.Binary, only: [fetch: 2]
  import JPEG.Util

  def match?(bytes) do
    case match(bytes) do
      {:ok} -> true
      {:error, _} -> false
    end
  end
  def match(<<0xFF, 0xE0>>), do: {:ok}
  def match(_), do: {:error, "Invalid APP0 marker"}

  def parse(header) do
    {length, tail} = JPEG.Stream.Binary.fetch(header.stream, 2)
    len = toUInt16(length)
    {identifier, remainder} = JPEG.Stream.Binary.fetch(tail, 5)
    cont_header = %Header{header | stream: remainder}
    IO.puts "output identifier for APP0:\n"
    IO.inspect identifier
    cond do
      JFIF.match?(identifier) -> JFIF.parse(cont_header, len - 7)
      JFXX.match?(identifier) -> JFXX.parse(cont_header, len - 7)
      true -> {:error, "Failed parsing APP0 segment"}
    end
  end

end
