# Copyright © 2015 Jonathan Storm <the.jonathan.storm@gmail.com>
# This work is free. You can redistribute it and/or modify it under the
# terms of the Do What The Fuck You Want To Public License, Version 2,
# as published by Sam Hocevar. See the COPYING.WTFPL file for more details.

defmodule Elixir.BorderPatrol.Repo.Migrations.CreateBorderProfiles do
  use Ecto.Migration

  def up do
    create table(:border_profiles) do
      add :name, :string, size: 255
      add :module, :string, size: 255
      add :description, :string, size: 255
    end

    create unique_index(:border_profiles, [:name])
  end

  def down do
    drop table(:border_profiles)
  end

  def change do
  end
end
