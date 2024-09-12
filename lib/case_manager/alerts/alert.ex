defmodule CaseManager.Alerts.Alert do
  use Ash.Resource, domain: CaseManager.Alerts, data_layer: AshPostgres.DataLayer

  postgres do
    table "alerts"
    repo CaseManager.Repo
  end

  actions do
    create :create
  end

  attributes do
    uuid_primary_key :id
    attribute :alert_id, :string
    attribute :team, :uuid
    attribute :title, :string
    attribute :description, :string
    attribute :risk_level, :string
    attribute :start_time, :utc_datetime
    attribute :end_time, :utc_datetime
    attribute :link, :string
    attribute :temp, :string
    attribute :additional_data, :map
    timestamps()
  end
end

