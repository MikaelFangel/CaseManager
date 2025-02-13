defmodule CaseManager.Teams.ArchivedUser do
  @moduledoc false
  use Ash.Resource,
    otp_app: :case_manager,
    domain: CaseManager.Teams,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshAdmin.Resource, AshArchival.Resource],
    primary_read_warning?: false

  postgres do
    table "user"
    repo CaseManager.Repo

    references do
      reference :team, on_delete: :delete, on_update: :update, name: "user_to_team_fkey"
    end
  end

  admin do
    actor?(true)
  end

  archive do
    exclude_read_actions :archived
  end

  attributes do
    uuid_primary_key :id
  end

  relationships do
    belongs_to :team, CaseManager.Teams.Team, allow_nil?: false
  end

  actions do
    read :archived do
      description "List all archived users."
      primary? true
      filter expr(not is_nil(archived_at))
    end
  end

  resource do
    description "A achived user on the application."
  end

  preparations do
    prepare build(load: [:team_type])
  end

  aggregates do
    first :team_type, :team, :type
  end
end
