# Copyright © 2015 Jonathan Storm <the.jonathan.storm@gmail.com>
# This work is free. You can redistribute it and/or modify it under the
# terms of the Do What The Fuck You Want To Public License, Version 2,
# as published by Sam Hocevar. See the COPYING.WTFPL file for more details.

defmodule BorderPatrol.Repo.Migrations.CreateEndpointToBorderProfile do
  use Ecto.Migration

  def up do
    create table(:endpoint_to_border_profile) do
      add :endpoint_id, references(:endpoints)
      add :border_profile_id, references(:border_profiles)
    end
  end

  def down do
    drop table(:endpoint_to_border_profile)
  end

  def change do
  end
end
