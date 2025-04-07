defmodule CaseManager.Incidents.Case do
  @moduledoc false
  use Ash.Resource, otp_app: :case_manager, domain: CaseManager.Incidents, data_layer: AshPostgres.DataLayer

  alias CaseManager.Accounts.User

  postgres do
    table "cases"
    repo(CaseManager.Repo)
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

    attribute :status, :atom do
      allow_nil? false
      public? true
    end

    attribute :priority, :atom do
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
    end

    belongs_to :soc, CaseManager.Organizations.SOC do
      allow_nil? false
    end
  end
end
