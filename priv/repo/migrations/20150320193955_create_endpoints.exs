defmodule BorderPatrol.Repo.Migrations.CreateEndpoints do
  use Ecto.Migration

  def up do
    create table(:endpoints) do
      add :name, :string, size: 255
      add :ip_addr, :inet
      add :mac_addr, :macaddr
    end
  end

  def down do
    drop table(:endpoints)
  end

  def change do
  end
end
