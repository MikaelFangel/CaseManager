defmodule CaseManager.Teams.User do
  @moduledoc """
  Resource representing a user in the system.
  """
  use Ash.Resource,
    otp_app: :case_manager,
    domain: CaseManager.Teams,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshAuthentication, AshAdmin.Resource],
    authorizers: [Ash.Policy.Authorizer]

  postgres do
    table "user"
    repo CaseManager.Repo

    references do
      reference :team, on_delete: :delete, on_update: :update, name: "user_to_team_fkey"
    end
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

      signing_secret fn _module, _map ->
        Application.fetch_env(:case_manager, :token_signing_secret)
      end
    end
  end

  admin do
    actor?(true)
  end

  policies do
    policy always() do
      authorize_if always()
    end
  end

  attributes do
    uuid_primary_key :id

    attribute :first_name, :string, allow_nil?: false, public?: true
    attribute :last_name, :string, allow_nil?: false, public?: true
    attribute :email, :ci_string, allow_nil?: false, public?: true
    attribute :hashed_password, :string, allow_nil?: false, sensitive?: true

    attribute :role, :atom do
      constraints one_of: [:admin, :analyst]
      allow_nil? false
      public? true
    end

    timestamps()
  end

  relationships do
    belongs_to :team, CaseManager.Teams.Team
  end

  actions do
    defaults [:read, :destroy, create: :*, update: :*]

    update :change_password do
      argument :password, :string do
        sensitive? true
        constraints min_length: 8, max_length: 32
      end

      argument :password_confirmation, :string do
        sensitive? true
        constraints min_length: 8, max_length: 32
      end

      change set_context(%{strategy_name: :password})
      validate AshAuthentication.Strategy.Password.PasswordConfirmationValidation
      change AshAuthentication.Strategy.Password.HashPasswordChange
    end
  end

  identities do
    identity :unique_email, [:email]
  end

  preparations do
    prepare build(load: [:team_type])
  end

  aggregates do
    first :team_type, :team, :type
  end

  calculations do
    calculate :full_name, :string, expr(first_name <> " " <> last_name)
  end
end
