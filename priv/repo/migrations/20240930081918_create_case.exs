defmodule CaseManager.Repo.Migrations.CreateCase do
  @moduledoc """
  Updates resources based on their most recent snapshots.

  This file was autogenerated with `mix ash_postgres.generate_migrations`
  """

  use Ecto.Migration

  def up do
    create table(:cases, primary_key: false) do
      add :id, :uuid, null: false, default: fragment("gen_random_uuid()"), primary_key: true
      add :title, :text, null: false
      add :description, :text
      add :status, :text, null: false, default: "In Progress"
      add :priority, :text, null: false

      add :team_id,
          references(:team,
            column: :id,
            name: "case_to_team_fkey",
            type: :uuid,
            prefix: "public",
            on_delete: :delete_all,
            on_update: :update_all
          ),
          null: false

      add :escalated, :boolean, null: false

      add :inserted_at, :utc_datetime_usec,
        null: false,
        default: fragment("(now() AT TIME ZONE 'utc')")

      add :updated_at, :utc_datetime_usec,
        null: false,
        default: fragment("(now() AT TIME ZONE 'utc')")
    end
  end

  def down do
    drop constraint(:cases, "case_to_team_fkey")

    drop table(:cases)
  end
end