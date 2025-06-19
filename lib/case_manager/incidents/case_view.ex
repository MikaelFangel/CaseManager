defmodule CaseManager.Incidents.CaseView do
  use Ash.Resource,
    otp_app: :case_manager,
    authorizers: [Ash.Policy.Authorizer],
    domain: CaseManager.Incidents,
    data_layer: AshPostgres.DataLayer,
    notifiers: [Ash.Notifier.PubSub]

  alias CaseManager.Incidents.Visibility

  postgres do
    table "case_views"
    repo(CaseManager.Repo)

    references do
      reference(:case, on_delete: :delete, on_update: :update, name: "case_views_case_id_fkey")
    end
  end

  actions do
    defaults [:destroy, update: :*]

    read :read do
      description "List all case read statuses."
      primary? true

      pagination offset?: true, keyset?: true, required?: false
    end

    read :for_user_and_case do
      description "Get read statuses for a specific user and case"
      argument :case_id, :uuid, allow_nil?: false

      filter expr(case_id == ^arg(:case_id) and user_id == ^actor(:id))
    end

    create :mark_as_read do
      description "Mark a case visibility channel as read for a user."
      accept [:last_viewed_at, :case_id]
      primary? true
      upsert? true
      upsert_identity :unique_user_case_visibility

      argument :visibility, Visibility, allow_nil?: false

      change set_attribute(:visibility, arg(:visibility))
      change relate_actor(:user)
    end
  end

  policies do
    bypass actor_attribute_equals(:super_admin?, true) do
      authorize_if always()
    end

    policy action_type(:create) do
      authorize_if always()
    end

    policy action_type(:read) do
      authorize_if expr(user_id == ^actor(:id))
      authorize_if expr(exists(case.soc.users, id == ^actor(:id)))
    end

    policy action_type(:update) do
      authorize_if expr(user_id == ^actor(:id))
    end

    policy action_type(:destroy) do
      authorize_if expr(user_id == ^actor(:id))
    end
  end

  attributes do
    uuid_primary_key :id

    attribute :visibility, Visibility do
      allow_nil? false
      public? true
      default :public
    end

    attribute :last_viewed_at, :utc_datetime_usec do
      allow_nil? false
      public? true
      default &DateTime.utc_now/0
    end
  end

  relationships do
    belongs_to :user, CaseManager.Accounts.User, allow_nil?: false
    belongs_to :case, CaseManager.Incidents.Case, allow_nil?: false
  end

  identities do
    identity :unique_user_case_visibility, [:user_id, :case_id, :visibility]
  end
end
