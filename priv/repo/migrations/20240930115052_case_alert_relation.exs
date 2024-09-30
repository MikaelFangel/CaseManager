defmodule CaseManager.Repo.Migrations.CaseAlertRelation do
  @moduledoc """
  Updates resources based on their most recent snapshots.

  This file was autogenerated with `mix ash_postgres.generate_migrations`
  """

  use Ecto.Migration

  def up do
    create table(:case_alert, primary_key: false) do
      add :case_id,
          references(:cases,
            column: :id,
            name: "case_alert_case_id_fkey",
            type: :uuid,
            prefix: "public"
          ),
          primary_key: true,
          null: false

      add :alert_id,
          references(:alert,
            column: :id,
            name: "case_alert_alert_id_fkey",
            type: :uuid,
            prefix: "public"
          ),
          primary_key: true,
          null: false
    end
  end

  def down do
    drop constraint(:case_alert, "case_alert_case_id_fkey")

    drop constraint(:case_alert, "case_alert_alert_id_fkey")

    drop table(:case_alert)
  end
end
