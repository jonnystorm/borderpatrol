# Copyright © 2015 Jonathan Storm <the.jonathan.storm@gmail.com>
# This work is free. You can redistribute it and/or modify it under the
# terms of the Do What The Fuck You Want To Public License, Version 2,
# as published by Sam Hocevar. See the COPYING.WTFPL file for more details.

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
