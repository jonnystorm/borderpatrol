defmodule BorderPatrol.IO do
  def write_to_file!(data, path) do
    {:ok, file} = File.open(path, [:write])
    :ok = IO.binwrite(file, data)
    :ok = File.close file
  end
end
