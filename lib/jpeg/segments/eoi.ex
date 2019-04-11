defmodule JPEG.Segment.EOI do
  def match?(bytes) do
    case match(bytes) do
      {:ok} -> true
      {:error, _} -> false
    end
  end
  def match(<<0xFF, 0xD9>>), do: {:ok}
  def match(_), do: {:error, "Invalid EOI (End Of Image) marker"}
end
