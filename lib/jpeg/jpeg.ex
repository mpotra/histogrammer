defmodule JPEG do
  alias __MODULE__
  alias JPEG.Header
  alias JPEG.Segment

  defstruct [:header, :data, :stream]

  def stream(path) when is_binary(path) do
    parse File.stream!(path, [:raw, :binary], 1)
  end

  defp parse(stream) do
    case parseHeader(stream) do
      {:ok, header} ->
        IO.puts "Header successfully parsed"
        jpeg = Map.put(%JPEG{}, :header, header)
      {:error, msg} -> {:error, msg}
    end
  end

  defp parseHeader(stream) do
    {filePrefix, tail} = JPEG.Stream.Binary.fetch(stream, 2)

    case filePrefix do
      # SOI (Start Of Image) marker match.
      <<0xFF, 0xD8>> ->
        Map.put(%Header{}, :stream, tail)
        |> parseHeaderSegments
      _-> {:error, "Invalid JPEG marker (SOI)"}
    end
  end

  defp parseHeaderSegments({:ok, header}), do: parseHeaderSegments(header)
  defp parseHeaderSegments(err = {:error, _}), do: err

  defp parseHeaderSegments(%Header{stream: stream} = header) do
    IO.puts "PARSE SEGMENTS PRE"
    IO.inspect stream
    {marker, tail} = JPEG.Stream.Binary.fetch(stream, 2)
    IO.puts "PARSE SEGMENTS"
    IO.inspect marker

    header = %Header{header | stream: tail}

    result = parseHeaderSegment(marker, header)

    case result do
      {:cont, header} -> parseHeaderSegments(header)
      {:halt, header} -> {:ok, header}
      {:error, msg} -> {:error, msg}
    end
  end

  defp parseHeaderSegment(marker, header) do
    case marker do
      # EOI (End of Image) marker
      <<0xFF, 0xD9>> ->
        {:error, "Unexpected EOI (End Of Image) marker"}
      # Comment marker
      <<0xFF, 0xFE>> ->
        {:cont, Segment.COM.parse(header)}
      # SOS (Start of Scan) marker
      <<0xFF, 0xDA>> ->
        {:halt, header}
      # APP0 marker
      <<0xFF, 0xE0>> ->
        {:cont, Segment.APP0.parse(header)}
      # APPn markers
      <<0xFF, b>> when is_integer(b) and b >= 0xE1 and b <= 0xEF ->
        {:cont, Segment.APPn.parse(header)}
      # DQT (Define Quantization Tables) marker
      <<0xFF, 0xDB>> ->
        {:cont, Segment.DQT.parse(header)}
      # DHT (Define Huffman Tables) marker
      <<0xFF, 0xC4>> ->
        {:cont, Segment.DHT.parse(header)}
      # SOF0 (Start of Frame, Baseline DCT)
      <<0xFF, 0xC0>> ->
        {:cont, Segment.SOF.parse(header, :baseline)}
      # SOF1 (Start of Frame, Extended DCT)
      <<0xFF, 0xC1>> ->
        {:cont, Segment.SOF.parse(header, :extended)}
      # SOF2 (Start of Frame, Progressive DCT)
      <<0xFF, 0xC2>> ->
        {:cont, Segment.SOF.parse(header, :progressive)}
      # Ignored marker (0xFF00)
      <<0xFF, 0x00>> ->
        {:cont, header}
      # Anything else
      _ -> {:error, "Unidentified segment marker"}
    end
  end
end
