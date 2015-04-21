# Copyright © 2015 Jonathan Storm <the.jonathan.storm@gmail.com>
# This work is free. You can redistribute it and/or modify it under the
# terms of the Do What The Fuck You Want To Public License, Version 2,
# as published by Sam Hocevar. See the COPYING.WTFPL file for more details.

defmodule BorderPatrol.Repo.Migrations.CreateJobs do
  use Ecto.Migration

  def up do
    create table(:jobs) do
      add :ticket, :integer
      add :edge_interface, references(:edge_interfaces)
      add :submitted_by, references(:users)
      add :created, :datetime
      add :ended, :datetime
      add :result, :integer
    end
  end

  def down do
    drop table(:jobs)
  end

  def change do
  end
end
