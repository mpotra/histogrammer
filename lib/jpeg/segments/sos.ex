defmodule JPEG.Segment.SOS do
  def match?(bytes) do
    case match(bytes) do
      {:ok} -> true
      {:error, _} -> false
    end
  end
  def match(<<0xFF, 0xDA>>), do: {:ok}
  def match(_), do: {:error, "Invalid SOS (Start Of Scan) marker"}
end
