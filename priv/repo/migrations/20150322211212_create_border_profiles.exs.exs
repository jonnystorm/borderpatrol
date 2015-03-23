defmodule :"Elixir.BorderPatrol.Repo.Migrations.CreateBorderProfiles.exs" do
  use Ecto.Migration

  def up do
    create table(:border_profiles) do
      add :name, :string, size: 255
      add :module, :string, size: 255
      add :description, :string, size: 255
    end
  end

  def down do
    drop table(:border_profiles)
  end

  def change do
  end
end
