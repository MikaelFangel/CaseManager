defmodule CaseManager.Repo.Migrations.AddCaseView do
  @moduledoc """
  Updates resources based on their most recent snapshots.

  This file was autogenerated with `mix ash_postgres.generate_migrations`
  """

  use Ecto.Migration

  def up do
    create table(:views, primary_key: false) do
      add :id, :uuid, null: false, default: fragment("gen_random_uuid()"), primary_key: true
      add :time, :utc_datetime

      add :user_id, references(:user, column: :id, name: "views_user_id_fkey", type: :uuid, prefix: "public"),
        null: false
    end

    create table(:case_views, primary_key: false) do
      add :case_id, references(:case, column: :id, name: "case_views_case_id_fkey", type: :uuid, prefix: "public"),
        primary_key: true,
        null: false

      add :view_id, references(:views, column: :id, name: "case_views_view_id_fkey", type: :uuid, prefix: "public"),
        primary_key: true,
        null: false
    end
  end

  def down do
    drop constraint(:case_views, "case_views_case_id_fkey")

    drop constraint(:case_views, "case_views_view_id_fkey")

    drop table(:case_views)

    drop constraint(:views, "views_user_id_fkey")

    drop table(:views)
  end
end
