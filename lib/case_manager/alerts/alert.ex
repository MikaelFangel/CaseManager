defmodule CaseManager.Alerts.Alert do
  use Ash.Resource,
    domain: CaseManager.Alerts,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshJsonApi.Resource]

  postgres do
    table "alerts"
    repo CaseManager.Repo
  end

  actions do
    create :create do
      accept [:alert_id, :title, :risk_level, :link]
    end

    read :read do
      primary? true
    end
  end

  attributes do
    uuid_primary_key :id

    attribute :alert_id, :string do
      allow_nil? false
    end

    attribute :team, :uuid

    attribute :title, :string do
      allow_nil? false
    end

    attribute :description, :string

    attribute :risk_level, :string do
      allow_nil? false
    end

    attribute :start_time, :utc_datetime
    attribute :end_time, :utc_datetime

    attribute :link, :string do
      allow_nil? false
    end

    attribute :additional_data, :map
    timestamps()
  end

  json_api do
    type "alert"
  end
end
