defmodule CaseManager.Cases.Comment do
  @moduledoc """
  Resource that represents a comment belonging to a case in the system.
  """
  use Ash.Resource,
    otp_app: :case_manager,
    domain: CaseManager.Cases,
    data_layer: AshPostgres.DataLayer,
    authorizers: [Ash.Policy.Authorizer]

  attributes do
    uuid_primary_key :id

    attribute :case_id, :uuid, allow_nil?: false, public?: true
    attribute :user_id, :uuid, allow_nil?: false, public?: true
    attribute :body, :string, allow_nil?: false, public?: true

    timestamps()
  end

  postgres do
    table "comment"
    repo CaseManager.Repo

    references do
      reference :case, on_delete: :delete, on_update: :update, name: "comment_to_case_fkey"
      reference :user, on_delete: :delete, on_update: :update, name: "comment_to_user_fkey"
    end
  end

  actions do
    defaults [:read, :destroy, create: :*, update: :*]
  end

  policies do
    policy action_type(:create) do
      authorize_if CaseManager.Policies.MSSPCreatePolicy
      authorize_if CaseManager.Policies.CaseOwnerPolicy
    end
  end

  relationships do
    belongs_to :case, CaseManager.Cases.Case
    belongs_to :user, CaseManager.Teams.User
  end
end
