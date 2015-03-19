defmodule BorderPatrol.Repo.Migrations.CreateEdgeInterfaces do
  use Ecto.Migration

  def up do
    create table(:edge_interfaces) do
      add :name, :string, size: 255
    end
  end

  def down do
    drop table(:edge_interfaces)
  end

  def change do
  end
end
