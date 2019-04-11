defmodule JPEG.Segment do
  @callback parse(Enumerable.t) :: {:ok, Enumerable.t} | {:error, String.t}
end
