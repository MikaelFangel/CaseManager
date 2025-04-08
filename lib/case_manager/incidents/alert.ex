defmodule CaseManager.Incidents.Alert do
  @moduledoc false
  use Ash.Resource, otp_app: :case_manager, domain: CaseManager.Incidents, data_layer: AshPostgres.DataLayer

  postgres do
    table "alerts"
    repo(CaseManager.Repo)
  end

  actions do
    create :create do
      description "Add an alert"
      primary? true

      accept :*
    end

    read :read do
      description "List alerts"
      primary? true

      pagination offset?: true, keyset?: true, required?: false
    end

    update :update do
      description "Change the alert data"
      primary? true
    end

    destroy :delete do
      description "Delete an alert"
    end
  end

  attributes do
    uuid_primary_key :id

    attribute :alert_id, :string do
      allow_nil? false
      public? true
    end

    attribute :title, :string do
      allow_nil? false
      public? true
    end

    attribute :description, :string do
      public? true
    end

    attribute :risk_level, CaseManager.Incidents.RiskLevel do
      allow_nil? false
      public? true
    end

    attribute :status, CaseManager.Incidents.Status do
      allow_nil? false
      public? true
      default :new
    end

    attribute :creation_time, :utc_datetime do
      allow_nil? false
      public? true
    end

    attribute :link, :string do
      allow_nil? false
      public? true
    end

    attribute :additional_data, :map do
      public? true
    end

    timestamps()
  end

  relationships do
    belongs_to :company, CaseManager.Organizations.Company
    has_many :comments, CaseManager.Incidents.Comment
  end
end
