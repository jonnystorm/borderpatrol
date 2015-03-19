defmodule BorderPatrol.Repo.Migrations.CreateEdgeDevices do
  use Ecto.Migration

  def up do
    create table(:edge_devices) do
      add :hostname, :string, size: 255
      add :ip_addr, :inet
    end
  end

  def down do
    drop table(:edge_devices)
  end

  def change do
  end
end
