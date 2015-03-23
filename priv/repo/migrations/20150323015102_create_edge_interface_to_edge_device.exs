defmodule BorderPatrol.Repo.Migrations.CreateEdgeInterfaceToEdgeDevice do
  use Ecto.Migration

  def up do
    create table(:edge_interface_to_edge_device) do
      add :edge_interface_id, references(:edge_interfaces)
      add :edge_device_id, references(:edge_devices)
    end
  end

  def down do
    drop table(:edge_interface_to_edge_device)
  end

  def change do
  end
end
