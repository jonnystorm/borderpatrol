# Copyright © 2015 Jonathan Storm <the.jonathan.storm@gmail.com>
# This work is free. You can redistribute it and/or modify it under the
# terms of the Do What The Fuck You Want To Public License, Version 2,
# as published by Sam Hocevar. See the COPYING.WTFPL file for more details.

defmodule BorderPatrol.Repo.Migrations.CreateEdgeInterfaces do
  use Ecto.Migration

  def up do
    create table(:edge_interfaces) do
      add :edge_device_id, references(:edge_devices)
      add :name, :string, size: 255
    end

    create unique_index(:edge_interfaces, [:edge_device_id, :name])
  end

  def down do
    drop table(:edge_interfaces)
  end

  def change do
  end
end
