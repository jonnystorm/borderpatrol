defmodule BorderPatrol.IO do
  def write_to_file!(data, path, mode \\ []) do
    file = File.open! path, [:write|mode]
    :ok = IO.binwrite(file, data)
    :ok = File.close file
  end
end
