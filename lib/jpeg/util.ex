defmodule JPEG.Util do
  require Bitwise

  def toUInt16([<<hi>>, <<lo>>]), do: toUInt16(<<hi, lo>>)
  def toUInt16(<<hi, lo>>) do
    Bitwise.bsl(hi, 8)
      |> Bitwise.bor(lo)
  end
end
