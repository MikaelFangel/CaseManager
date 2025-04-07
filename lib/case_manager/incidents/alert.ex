defmodule CaseManager.Incidents.Alert do
  @moduledoc false
  use Ash.Resource, otp_app: :case_manager, domain: CaseManager.Incidents, data_layer: AshPostgres.DataLayer

  postgres do
    table "alerts"
    repo(CaseManager.Repo)
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

    attribute :risk_level, :atom do
      allow_nil? false
      public? true
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
  end
end
