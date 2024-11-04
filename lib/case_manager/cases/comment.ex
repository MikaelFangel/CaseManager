defmodule CaseManager.Cases.Comment do
  @moduledoc """
  Resource that represents a comment belonging to a case in the system.
  """
  use Ash.Resource,
    otp_app: :case_manager,
    domain: CaseManager.Cases,
    data_layer: AshPostgres.DataLayer,
    notifiers: [Ash.Notifier.PubSub],
    authorizers: [Ash.Policy.Authorizer]

  postgres do
    table "comment"
    repo CaseManager.Repo

    references do
      reference :case, on_delete: :delete, on_update: :update, name: "comment_to_case_fkey"
      reference :user, on_delete: :delete, on_update: :update, name: "comment_to_user_fkey"
    end
  end

  pub_sub do
    module CaseManagerWeb.Endpoint

    prefix "comment"
    publish :create, ["created"]
  end

  policies do
    policy action_type(:create) do
      authorize_if CaseManager.Policies.MSSPCreatePolicy
      authorize_if CaseManager.Policies.CaseOwnerPolicy
    end

    policy action_type(:read) do
      authorize_if always()
    end
  end

  attributes do
    uuid_primary_key :id

    attribute :case_id, :uuid, allow_nil?: false, public?: true
    attribute :user_id, :uuid, allow_nil?: false, public?: true
    attribute :body, :string, allow_nil?: false, public?: true

    timestamps()
  end

  relationships do
    belongs_to :case, CaseManager.Cases.Case
    belongs_to :user, CaseManager.Teams.User
  end

  actions do
    defaults [:destroy, create: :*, update: :*]

    read :read do
      primary? true
      prepare build(load: [user: [:team]])
    end
  end
end
