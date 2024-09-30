defmodule CaseManager.Repo.Migrations.RenameCasesToCase do
  @moduledoc """
  Updates resources based on their most recent snapshots.

  This file was autogenerated with `mix ash_postgres.generate_migrations`
  """

  use Ecto.Migration

  def up do
    drop constraint(:case_alert, "case_alert_case_id_fkey")

    create table(:case, primary_key: false) do
      add :id, :uuid, null: false, default: fragment("gen_random_uuid()"), primary_key: true
    end

    alter table(:case_alert) do
      modify :case_id,
             references(:case,
               column: :id,
               name: "case_alert_case_id_fkey",
               type: :uuid,
               prefix: "public"
             )
    end

    alter table(:case) do
      add :title, :text, null: false
      add :description, :text
      add :status, :text, null: false, default: "In Progress"
      add :priority, :text, null: false
      add :assignee_id, :uuid

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
    drop constraint(:case, "case_to_team_fkey")

    alter table(:case) do
      remove :updated_at
      remove :inserted_at
      remove :escalated
      remove :team_id
      remove :assignee_id
      remove :priority
      remove :status
      remove :description
      remove :title
    end

    drop constraint(:case_alert, "case_alert_case_id_fkey")

    alter table(:case_alert) do
      modify :case_id,
             references(:cases,
               column: :id,
               name: "case_alert_case_id_fkey",
               type: :uuid,
               prefix: "public"
             )
    end

    drop table(:case)
  end
end
