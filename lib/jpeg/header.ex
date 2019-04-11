defmodule JPEG.Header do
  #alias __MODULE__

  defstruct segments: [],
            comments: [],
            frames: [],
            stream: nil
end
