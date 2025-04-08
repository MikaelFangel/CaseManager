defmodule CaseManager.Repo.Migrations.AddStatusToAlert do
  @moduledoc """
  Updates resources based on their most recent snapshots.

  This file was autogenerated with `mix ash_postgres.generate_migrations`
  """

  use Ecto.Migration

  def up do
    alter table(:comments) do
      modify(:case_id, :uuid, null: true)
      add(:alert_id, references(:alerts, column: :id, name: "comments_alert_id_fkey", type: :uuid, prefix: "public"))
    end

    alter table(:alerts) do
      add(:status, :text, null: false, default: "new")
    end
  end

  def down do
    alter table(:alerts) do
      remove(:status)
    end

    drop(constraint(:comments, "comments_alert_id_fkey"))

    alter table(:comments) do
      remove(:alert_id)
      modify(:case_id, :uuid, null: false)
    end
  end
end
