defmodule CaseManager.Teams.Email do
  @moduledoc """
  Resource that represents emails. This resources is different from the email used for authentication.
  """
  use Ash.Resource,
    otp_app: :case_manager,
    domain: CaseManager.Teams,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "email"
    repo CaseManager.Repo

    references do
      reference :team, on_delete: :delete, on_update: :update, name: "email_to_team_fkey"
    end
  end

  attributes do
    uuid_primary_key :id

    attribute :email, :string, allow_nil?: false, public?: true

    timestamps()
  end

  relationships do
    belongs_to :team, CaseManager.Teams.Team do
      allow_nil? false
    end
  end

  actions do
    defaults [:read, :destroy, create: :*, update: :*]
  end
end
