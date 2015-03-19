defmodule BorderPatrol.Repo.Migrations.CreateEdgeInterfaceToEndpoint do
  use Ecto.Migration

  def up do
    create table(:edge_interface_to_endpoint) do
      add :edge_interface_id, references(:edge_interfaces)
      add :endpoint_id, references(:endpoints)
    end
  end

  def down do
    drop table(:edge_interface_to_endpoint)
  end

  def change do
  end
end
