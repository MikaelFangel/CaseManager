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
    table "alert"
    repo CaseManager.Repo

    references do
      reference :team, on_delete: :delete, on_update: :update, name: "alert_to_team_fkey"
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

      change fn changeset, _context ->
        changeset
        |> Ash.Changeset.get_attribute(:risk_level)
        |> case do
          nil ->
            changeset

          risk_level ->
            Ash.Changeset.change_attribute(changeset, :risk_level, String.capitalize(risk_level))
        end
      end
    end

    read :read do
      primary? true
      prepare build(load: [:team])

      pagination do
        required?(true)
        offset?(true)
        countable(true)
        default_limit(20)
      end
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

    attribute :additional_data, :map do
      default %{}
      sortable? false
    end

    timestamps()
  end

  relationships do
    belongs_to :team, CaseManager.Teams.Team do
      allow_nil? false
    end

    many_to_many :case, CaseManager.Cases.Case do
      through CaseManager.Relationships.CaseAlert
      source_attribute_on_join_resource :alert_id
      destination_attribute_on_join_resource :case_id
    end
  end

  validations do
    validate one_of(:risk_level, ["Info", "Low", "Medium", "High", "Critical"])

    # Ensure the start_time must be before end_time
    validate fn changeset, _context ->
      start_time = Ash.Changeset.get_attribute(changeset, :start_time)
      end_time = Ash.Changeset.get_attribute(changeset, :end_time)

      # If either start time or end time is nil, we don't need to validate
      # as the allow_nil? false on the attributes will return missing_attribute error instead
      if start_time && end_time && DateTime.before?(start_time, end_time) do
        :ok
      else
        {:error, message: "start_time must be before end_time"}
      end
    end
  end

  json_api do
    type "alert"
  end
end
