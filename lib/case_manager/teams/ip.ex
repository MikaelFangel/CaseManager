defmodule CaseManager.Teams.IP do
  @moduledoc """
  Resource to represents an IP address of either version v4 og v6.
  """
  use Ash.Resource,
    otp_app: :case_manager,
    domain: CaseManager.Teams,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshAdmin.Resource]

  postgres do
    table "ip"
    repo CaseManager.Repo

    references do
      reference :team, on_delete: :delete, on_update: :update, name: "ip_to_team_fkey"
    end
  end

  admin do
    create_actions([])
  end

  attributes do
    uuid_primary_key :id

    attribute :ip, :string, allow_nil?: false, public?: true

    attribute :version, :atom do
      constraints one_of: [:v4, :v6]
      public? true
    end

    timestamps()
  end

  relationships do
    belongs_to :team, CaseManager.Teams.Team, allow_nil?: false
  end

  actions do
    defaults [:read, :destroy, create: :*, update: :*]
  end
end
