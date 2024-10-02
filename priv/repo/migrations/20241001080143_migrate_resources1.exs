defmodule CaseManager.Repo.Migrations.MigrateResources1 do
  @moduledoc """
  Updates resources based on their most recent snapshots.

  This file was autogenerated with `mix ash_postgres.generate_migrations`
  """

  use Ecto.Migration

  def up do
    create table(:user, primary_key: false) do
      add :id, :uuid, null: false, default: fragment("gen_random_uuid()"), primary_key: true
      add :first_name, :text, null: false
      add :last_name, :text, null: false
      add :email_id, :uuid, null: false

      add :team_id,
          references(:team,
            column: :id,
            name: "user_to_team_fkey",
            type: :uuid,
            prefix: "public",
            on_delete: :delete_all,
            on_update: :update_all
          ),
          null: false

      add :role, :text, null: false

      add :inserted_at, :utc_datetime_usec,
        null: false,
        default: fragment("(now() AT TIME ZONE 'utc')")

      add :updated_at, :utc_datetime_usec,
        null: false,
        default: fragment("(now() AT TIME ZONE 'utc')")
    end

    alter table(:email) do
      add :user_id,
          references(:user,
            column: :id,
            name: "email_user_id_fkey",
            type: :uuid,
            prefix: "public"
          )
    end
  end

  def down do
    drop constraint(:email, "email_user_id_fkey")

    alter table(:email) do
      remove :user_id
    end

    drop constraint(:user, "user_to_team_fkey")

    drop table(:user)
  end
end