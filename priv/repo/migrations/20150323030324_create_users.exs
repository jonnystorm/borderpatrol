defmodule BorderPatrol.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def up do
    create table(:users) do
      add :name, :string, size: 255
    end
  end

  def down do
    drop table(:users)
  end

  def change do
  end
end
