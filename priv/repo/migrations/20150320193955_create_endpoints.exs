# Copyright © 2015 Jonathan Storm <the.jonathan.storm@gmail.com>
# This work is free. You can redistribute it and/or modify it under the
# terms of the Do What The Fuck You Want To Public License, Version 2,
# as published by Sam Hocevar. See the COPYING.WTFPL file for more details.

defmodule BorderPatrol.Repo.Migrations.CreateEndpoints do
  use Ecto.Migration

  def up do
    create table(:endpoints) do
      add :name, :string, size: 255
      add :ip_addr, :inet
      add :mac_addr, :macaddr
    end

    create unique_index(:endpoints, [:name, :ip_addr, :mac_addr])
  end

  def down do
    drop table(:endpoints)
  end

  def change do
  end
end
