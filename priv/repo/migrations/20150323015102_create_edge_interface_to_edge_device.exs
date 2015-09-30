# Copyright © 2015 Jonathan Storm <the.jonathan.storm@gmail.com>
# This work is free. You can redistribute it and/or modify it under the
# terms of the Do What The Fuck You Want To Public License, Version 2,
# as published by Sam Hocevar. See the COPYING.WTFPL file for more details.

defmodule BorderPatrol.Repo.Migrations.CreateEdgeInterfaceToEdgeDevice do
  use Ecto.Migration

  def up do
    create table(:edge_interface_to_edge_device) do
      add :edge_interface_id, references(:edge_interfaces)
      add :edge_device_id, references(:edge_devices)
    end

    create unique_index(:edge_interface_to_edge_device, [:edge_interface_id])
  end

  def down do
    drop table(:edge_interface_to_edge_device)
  end

  def change do
  end
end
