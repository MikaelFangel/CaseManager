defmodule CaseManager.Repo.Migrations.Enable_GIN do
  @moduledoc """
  Updates resources based on their most recent snapshots.

  This file was autogenerated with `mix ash_postgres.generate_migrations`
  """

  use Ecto.Migration

  def up do
    create index(:case, ["title gin_trgm_ops"], name: "case_title_gin_index", using: "GIN")

    create index(:alert, ["title gin_trgm_ops"], name: "alert_title_gin_index", using: "GIN")
  end

  def down do
    drop_if_exists index(:alert, ["title gin_trgm_ops"], name: "alert_title_gin_index")

    drop_if_exists index(:case, ["title gin_trgm_ops"], name: "case_title_gin_index")
  end
end
