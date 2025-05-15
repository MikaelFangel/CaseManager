defmodule CaseManager.Incidents.Case do
  @moduledoc false
  use Ash.Resource,
    otp_app: :case_manager,
    domain: CaseManager.Incidents,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshJsonApi.Resource]

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

    timestamps()
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
