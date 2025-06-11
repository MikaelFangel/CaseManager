defmodule CaseManager.Incidents.Case do
  @moduledoc false
  use Ash.Resource,
    otp_app: :case_manager,
    authorizers: [Ash.Policy.Authorizer],
    data_layer: AshPostgres.DataLayer,
    domain: CaseManager.Incidents,
    extensions: [AshJsonApi.Resource],
    notifiers: [Ash.Notifier.PubSub]

  alias CaseManager.Accounts.User

  json_api do
    type "case"
  end

  postgres do
    table "cases"
    repo(CaseManager.Repo)
  end

  actions do
    create :create do
      description "Add an case"
      primary? true

      accept :*

      argument :alerts, {:array, :string}

      change manage_relationship(:alerts, type: :append_and_remove)
      change relate_actor(:reporter)
    end

    read :read do
      description "List cases"
      primary? true

      pagination offset?: true, keyset?: true, required?: false
    end

    read :search do
      description "Search cases."

      argument :query, :ci_string do
        constraints allow_empty?: true
        default ""
      end

      filter expr(contains(title, ^arg(:query)) or exists(alerts, contains(title, ^arg(:query))))

      pagination offset?: true, keyset?: true, required?: false
    end

    update :update do
      description "Change the case data"
      primary? true

      accept [:*]
    end

    destroy :delete do
      description "Delete an case"
    end

    update :add_comment do
      description "Add a comment to a case"
      require_atomic? false

      argument :comment, :map

      change manage_relationship(:comment, :comments, type: :create)
    end

    update :assign_user do
      description "Assign a user to the case"
      argument :user_id, :uuid, allow_nil?: true
      require_atomic? false

      change set_attribute(:assignee_id, arg(:user_id))
    end

  end

  policies do
    bypass AshAuthentication.Checks.AshAuthenticationInteraction do
      authorize_if always()
    end

    bypass actor_attribute_equals(:super_admin?, true) do
      authorize_if always()
    end

    policy action_type(:read) do
      authorize_if expr(soc.users == ^actor(:id))
      authorize_if expr(company.users == ^actor(:id) && escalated)
    end

    policy action_type(:create) do
      authorize_if always()
      authorize_if expr(soc.users == ^actor(:id))
    end

    policy action(:update) do
      authorize_if expr(soc.users == ^actor(:id))
    end

    policy action(:add_comment) do
      authorize_if expr(soc.users == ^actor(:id))
      authorize_if expr(company.users == ^actor(:id) && escalated)
    end

    policy action(:assign_user) do
      authorize_if expr(soc.users == ^actor(:id))
    end

    policy action_type(:destroy) do
      authorize_if actor_attribute_equals(:super_admin?, true)
    end
  end

  pub_sub do
    module CaseManagerWeb.Endpoint

    prefix "case"
    publish :create, [[:company_id, :soc_id, nil], [:id, nil]]
    publish :update, [[:company_id, :soc_id, nil], [:id, nil]]
    publish :assign_user, [[:company_id, :soc_id, nil], [:id, nil]]
  end

  attributes do
    uuid_primary_key :id

    attribute :title, :string do
      allow_nil? false
      public? true
    end

    attribute :description, :string do
      public? true
    end

    attribute :status, CaseManager.Incidents.CaseStatus do
      allow_nil? false
      public? true
      default :new
    end

    attribute :resolution_type, CaseManager.Incidents.Resolution do
      public? true
    end

    attribute :severity, CaseManager.Incidents.Severity do
      public? true
    end

    attribute :escalated, :boolean do
      public? true
    end

    timestamps(public?: true)
  end

  relationships do
    belongs_to :reporter, User
    belongs_to :assignee, User

    belongs_to :company, CaseManager.Organizations.Company do
      allow_nil? false
      public? true
    end

    belongs_to :soc, CaseManager.Organizations.SOC do
      allow_nil? false
      public? true
    end

    many_to_many :alerts, CaseManager.Incidents.Alert do
      through CaseManager.Incidents.CaseAlert
      public? true
    end

    has_many :comments, CaseManager.Incidents.Comment do
      public? true
      sort inserted_at: :desc
    end
  end
end
