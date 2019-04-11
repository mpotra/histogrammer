defmodule JPEG.Segment.SOI do
  @behaviour JPEG.Segment

  def match?(bytes) do
    case match(bytes) do
      {:ok} -> true
      {:error, _} -> false
    end
  end
  def match(<<0xFF, 0xD8>>), do: {:ok}
  def match(_), do: {:error, "Invalid SOI (Start Of Image) marker"}
end
