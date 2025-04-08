defmodule CaseManager.Incidents.Case do
  @moduledoc false
  use Ash.Resource, otp_app: :case_manager, domain: CaseManager.Incidents, data_layer: AshPostgres.DataLayer

  alias CaseManager.Accounts.User

  postgres do
    table "cases"
    repo(CaseManager.Repo)
  end

  actions do
    create :create do
      description "Add an case"
      primary? true

      accept :*
    end

    read :read do
      description "List cases"
      primary? true

      pagination offset?: true, keyset?: true, required?: false
    end

    update :update do
      description "Change the case data"
      primary? true
    end

    destroy :delete do
      description "Delete an case"
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
    end

    attribute :resolution_type, CaseManager.Incidents.Resolution do
      public? true
    end

    attribute :risk_level, CaseManager.Incidents.RiskLevel do
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

    has_many :comments, CaseManager.Incidents.Comment do
      public? true
    end
  end
end
