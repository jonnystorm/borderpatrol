defmodule Extensions.MacAddr do
  alias Postgrex.TypeInfo

  @behaviour Postgrex.Extension

  def init(_parameters, _opts), do: nil

  def matching(_library), do: [type: "macaddr"]

  def format(_library), do: :text

  def encode(%TypeInfo{type: "macaddr"}, binary, _state, _library), do: binary

  def decode(%TypeInfo{type: "macaddr"}, macaddr, _state, _library), do: macaddr
end

