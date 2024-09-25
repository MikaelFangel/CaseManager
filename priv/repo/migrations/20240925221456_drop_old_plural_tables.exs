defmodule CaseManager.Repo.Migrations.DropOldPluralTables do
  use Ecto.Migration

  def up do
    drop table(:alerts)
    drop table(:teams)
  end

  def down do
      drop table(:alert)
      drop table(:team)

      create table(:teams, primary_key: false) do
      add :id, :uuid, null: false, default: fragment("gen_random_uuid()"), primary_key: true
      add :ip, :text
      add :name, :text
      add :email, :text
      add :phone, :text
      add :is_mssp, :boolean, default: false

      add :inserted_at, :utc_datetime_usec,
        null: false,
        default: fragment("(now() AT TIME ZONE 'utc')")

      add :updated_at, :utc_datetime_usec,
        null: false,
        default: fragment("(now() AT TIME ZONE 'utc')")
    end

    create table(:alerts, primary_key: false) do
      add :id, :uuid, null: false, default: fragment("gen_random_uuid()"), primary_key: true
      add :alert_id, :text, null: false

      add :team_id,
          references(:teams,
            column: :id,
            name: "alerts_to_teams_fkey",
            type: :uuid,
            prefix: "public",
            on_delete: :delete_all,
            on_update: :update_all
          ),
          null: false

      add :title, :text, null: false
      add :description, :text
      add :risk_level, :text, null: false
      add :start_time, :utc_datetime, null: false
      add :end_time, :utc_datetime, null: false
      add :link, :text, null: false
      add :additional_data, :map, default: %{}

      add :inserted_at, :utc_datetime_usec,
        null: false,
        default: fragment("(now() AT TIME ZONE 'utc')")

      add :updated_at, :utc_datetime_usec,
        null: false,
        default: fragment("(now() AT TIME ZONE 'utc')")
    end

    execute("ALTER TABLE alerts alter CONSTRAINT alerts_to_teams_fkey NOT DEFERRABLE")
  end
end
