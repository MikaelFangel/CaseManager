defmodule CaseManager.Repo.Migrations.DropTokens do
  use Ecto.Migration

  def change do
    drop table("tokens")
  end
end
