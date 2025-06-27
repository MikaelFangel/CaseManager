defmodule CaseManager.Repo.Migrations.AddOban do
  @moduledoc false
  use Ecto.Migration
  use Ecto.Migration

  def up, do: Oban.Migration.up()

  def down, do: Oban.Migration.down(version: 1)
end
