defmodule JPEGFormat do
  require Bitwise

  @vdctZigZag {
       0,
       1,  8,
      16,  9,  2,
       3, 10, 17, 24,
      32, 25, 18, 11, 4,
       5, 12, 19, 26, 33, 40,
      48, 41, 34, 27, 20, 13,  6,
       7, 14, 21, 28, 35, 42, 49, 56,
      57, 50, 43, 36, 29, 22, 15,
      23, 30, 37, 44, 51, 58,
      59, 52, 45, 38, 31,
      39, 46, 53, 60,
      61, 54, 47,
      55, 62,
      63
  }

  @dctCos1 4017   # cos(pi/16)
  @dctSin  799   # sin(pi/16)
  @dctCos3 3406   # cos(3*pi/16)
  @dctSin3 2276   # sin(3*pi/16)
  @dctCos6 1567   # cos(6*pi/16)
  @dctSin6 3784   # sin(6*pi/16)
  @dctSqrt2 5793   # sqrt(2)
  @dctSqrt1d2 2896  # sqrt(2) / 2

  def readUint16(<<hi, lo>>) do
    Bitwise.bsl(hi, 8)
    |> Bitwise.bor(lo)
  end
end
