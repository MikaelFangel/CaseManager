defmodule CaseManager.Alerts.Alert do
  @moduledoc """
  Resource that represents an alert in the system. The Resource is to be used by the JSON API 
  and also to view and edit alerts within the application.
  """
  use Ash.Resource,
    domain: CaseManager.Alerts,
    data_layer: AshPostgres.DataLayer,
    notifiers: [Ash.Notifier.PubSub],
    extensions: [AshJsonApi.Resource]

  @derive {Jason.Encoder,
           only: [
             :id,
             :alert_id,
             :team_id,
             :title,
             :description,
             :risk_level,
             :start_time,
             :end_time,
             :link,
             :additional_data
           ]}

  resource do
    plural_name :alerts
  end

  postgres do
    table "alerts"
    repo CaseManager.Repo

    references do
      reference :team, on_delete: :delete, on_update: :update, name: "alerts_to_teams_fkey"
    end
  end

  pub_sub do
    module CaseManagerWeb.Endpoint

    prefix "alert"

    publish :create, ["created"]
  end

  actions do
    create :create do
      accept [
        :alert_id,
        :title,
        :risk_level,
        :start_time,
        :end_time,
        :link,
        :additional_data,
        :team_id
      ]

      # Ensure the start time is before the end time
      validate fn changeset, _context ->
        start_time = Ash.Changeset.get_attribute(changeset, :start_time)
        end_time = Ash.Changeset.get_attribute(changeset, :end_time)

        cond do
          start_time == nil -> :ok
          end_time == nil -> :ok
          DateTime.before?(start_time, end_time) -> :ok
          true -> {:error, "Start time must be before end time"}
        end
      end
    end

    read :read do
      primary? true
      prepare build(load: [:team])
    end
  end

  attributes do
    uuid_primary_key :id

    attribute :alert_id, :string do
      allow_nil? false
    end

    attribute :team_id, :uuid do
      allow_nil? false
    end

    attribute :title, :string do
      allow_nil? false
    end

    attribute :description, :string

    attribute :risk_level, :string do
      allow_nil? false
    end

    attribute :start_time, :utc_datetime do
      allow_nil? false
    end

    attribute :end_time, :utc_datetime do
      allow_nil? false
    end

    attribute :link, :string do
      allow_nil? false
    end

    attribute :additional_data, :map
    timestamps()
  end

  relationships do
    belongs_to :team, CaseManager.Teams.Team do
      attribute_type :uuid
      attribute_writable? true
      allow_nil? false
    end
  end

  json_api do
    type "alert"
  end
end
