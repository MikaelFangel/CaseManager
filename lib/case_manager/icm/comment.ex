defmodule CaseManager.ICM.Comment do
  @moduledoc false
  use Ash.Resource,
    otp_app: :case_manager,
    domain: CaseManager.ICM,
    data_layer: AshPostgres.DataLayer,
    notifiers: [Ash.Notifier.PubSub],
    authorizers: [Ash.Policy.Authorizer],
    extensions: [AshAdmin.Resource],
    primary_read_warning?: false

  postgres do
    table "comment"
    repo CaseManager.Repo

    references do
      reference :case, on_delete: :delete, on_update: :update, name: "comment_to_case_fkey"
      reference :user, on_delete: :nilify, on_update: :update, name: "comment_to_user_fkey"
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

  admin do
    create_actions([])
  end

  attributes do
    uuid_primary_key :id

    attribute :body, :string, allow_nil?: false, public?: true

    timestamps()
  end

  relationships do
    belongs_to :case, CaseManager.ICM.Case, allow_nil?: false
    belongs_to :user, CaseManager.Teams.User
  end

  actions do
    defaults [:destroy, update: :*]

    create :create do
      description "Create a comment."
      accept :*
      primary? true

      change relate_actor(:user)
    end

    read :read do
      description "List all comments"
      primary? true
      prepare build(load: [user: [:team, :full_name]])
    end
  end

  resource do
    description "A comment is the messages communicated between MSSPs and customers on cases."
  end
end
