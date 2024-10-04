defmodule CaseManager.Repo.Migrations.ChangeEmailToAttr do
  @moduledoc """
  Updates resources based on their most recent snapshots.

  This file was autogenerated with `mix ash_postgres.generate_migrations`
  """

  use Ecto.Migration

  def up do
    alter table(:user) do
      remove :email_id
      add :email, :citext, null: false
      add :hashed_password, :text, null: false
    end

    create unique_index(:user, [:email], name: "user_unique_email_index")
  end

  def down do
    drop_if_exists unique_index(:user, [:email], name: "user_unique_email_index")

    alter table(:user) do
      remove :hashed_password
      remove :email
      add :email_id, :uuid, null: false
    end
  end
end