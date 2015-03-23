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
