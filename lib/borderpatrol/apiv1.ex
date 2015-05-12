defmodule BorderPatrol.APIv1 do
  use Urna.Adapter
  use Jazz

  def accept?("application/borderpatrol-v1"), do: true
  def accept?(""),                            do: true
  def accept?(_),                             do: false

  def encode(_, value) do
    { "application/borderpatrol-v1", JSON.encode!(value) }
  end

  def decode(_, string) do
    JSON.decode(string)
  end
end

