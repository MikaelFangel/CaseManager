defmodule CaseManager.Repo.Migrations.MigrateResources2 do
  @moduledoc """
  Updates resources based on their most recent snapshots.

  This file was autogenerated with `mix ash_postgres.generate_migrations`
  """

  use Ecto.Migration

  def up do
    alter table(:case) do
      add :internal_note, :text
    end
  end

  def down do
    alter table(:case) do
      remove :internal_note
    end
  end
end
