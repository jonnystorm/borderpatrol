defmodule Extensions.Inet do
  alias Postgrex.TypeInfo

  @behaviour Postgrex.Extension

  def init(_parameters, _opts), do: nil

  def matching(_library), do: [type: "inet"]

  def format(_library), do: :text

  def encode(%TypeInfo{type: "inet"}, binary, _state, _library), do: binary

  def decode(%TypeInfo{type: "inet"}, inet, _state, _library), do: inet
end

