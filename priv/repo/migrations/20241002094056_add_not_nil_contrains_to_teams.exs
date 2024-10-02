defmodule CaseManager.Repo.Migrations.AddNotNilContrainsToTeams do
  @moduledoc """
  Updates resources based on their most recent snapshots.

  This file was autogenerated with `mix ash_postgres.generate_migrations`
  """

  use Ecto.Migration

  def up do
    alter table(:team) do
      modify :type, :text, null: false
      modify :name, :text, null: false
    end
  end

  def down do
    alter table(:team) do
      modify :name, :text, null: true
      modify :type, :text, null: true
    end
  end
end