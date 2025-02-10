defmodule CaseManager.Teams.Phone do
  @moduledoc """
  Resource that represents a phone number.
  """
  use Ash.Resource,
    otp_app: :case_manager,
    domain: CaseManager.Teams,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshAdmin.Resource]

  postgres do
    table "phone"
    repo CaseManager.Repo

    references do
      reference :team, on_delete: :delete, on_update: :update, name: "phone_to_team_fkey"
    end
  end

  admin do
    create_actions([])
  end

  attributes do
    uuid_primary_key :id

    attribute :country_code, :string, public?: true
    attribute :phone, :string, allow_nil?: false, public?: true

    timestamps()
  end

  relationships do
    belongs_to :team, CaseManager.Teams.Team, allow_nil?: false
  end

  actions do
    defaults [:read, :destroy, create: :*, update: :*]
  end

  resource do
    description "Phone number to contact a team."
  end
end
