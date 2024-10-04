defmodule CaseManager.Teams.User do
  @moduledoc """
  Resource representing a user in the system.
  """
  use Ash.Resource,
    otp_app: :case_manager,
    domain: CaseManager.Teams,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshAuthentication],
    authorizers: [Ash.Policy.Authorizer]

  attributes do
    uuid_primary_key :id

    attribute :first_name, :string do
      public? true
    end

    attribute :last_name, :string do
      public? true
    end

    attribute :email, :ci_string do
      allow_nil? false
      public? true
    end

    attribute :hashed_password, :string, allow_nil?: false, sensitive?: true

    attribute :team_id, :uuid do
      public? true
    end

    attribute :role, :string do
      public? true
    end

    timestamps()
  end

  authentication do
    strategies do
      password :password do
        identity_field :email
        register_action_accept([:first_name, :last_name, :team_id, :role])
      end
    end

    tokens do
      enabled? true
      token_resource CaseManager.Teams.Token

      signing_secret fn _, _ ->
        Application.fetch_env(:case_manager, :token_signing_secret)
      end
    end
  end

  identities do
    identity :unique_email, [:email]
  end

  policies do
    policy always() do
      authorize_if always()
    end
  end

  postgres do
    table "user"
    repo CaseManager.Repo

    references do
      reference :team, on_delete: :delete, on_update: :update, name: "user_to_team_fkey"
    end
  end

  actions do
    defaults [:read, :destroy, create: :*, update: :*]

    read :get_by_id do
      argument :id, :uuid
      filter expr(id == ^arg(:id))
    end
  end

  code_interface do
    define :get_by_id, action: :get_by_id, args: [:id], get?: true
  end

  validations do
    validate one_of(:role, ["Admin", "Analyst"])
  end

  relationships do
    belongs_to :team, CaseManager.Teams.Team
  end
end
