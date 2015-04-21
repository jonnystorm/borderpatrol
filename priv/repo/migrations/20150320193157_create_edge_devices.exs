# Copyright © 2015 Jonathan Storm <the.jonathan.storm@gmail.com>
# This work is free. You can redistribute it and/or modify it under the
# terms of the Do What The Fuck You Want To Public License, Version 2,
# as published by Sam Hocevar. See the COPYING.WTFPL file for more details.

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
