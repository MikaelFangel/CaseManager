defmodule CaseManager.Teams.User do
  @moduledoc """
  Resource representing a user in the system.
  """
  use Ash.Resource,
    otp_app: :case_manager,
    domain: CaseManager.Teams,
    data_layer: AshPostgres.DataLayer

  attributes do
    uuid_primary_key :id

    attribute :first_name, :string do
      allow_nil? false
    end

    attribute :last_name, :string do
      allow_nil? false
    end

    attribute :email_id, :uuid do
      allow_nil? false
    end

    attribute :team_id, :uuid do
      allow_nil? false
    end

    attribute :role, :string do
      allow_nil? false
    end

    timestamps()
  end

  postgres do
    table "user"
    repo CaseManager.Repo

    references do
      reference :team, on_delete: :delete, on_update: :update, name: "user_to_team_fkey"
      reference :email, on_delete: :delete, on_update: :update, name: "user_to_email_fkey"
    end
  end

  actions do
    defaults [:read, :destroy, create: :*, update: :*]
  end

  validations do
    validate one_of(:role, ["Admin", "Analyst"])
  end

  relationships do
    belongs_to :team, CaseManager.Teams.Team
    has_one :email, CaseManager.ContactInfos.Email
  end
end
