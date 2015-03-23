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
