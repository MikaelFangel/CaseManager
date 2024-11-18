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
             :creation_time,
             :link,
             :additional_data
           ]}

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

  json_api do
    type "alert"
  end

  attributes do
    uuid_primary_key :id

    attribute :alert_id, :string, allow_nil?: false
    attribute :title, :string, allow_nil?: false
    attribute :description, :string
    attribute :creation_time, :utc_datetime, allow_nil?: false
    attribute :link, :string, allow_nil?: false

    attribute :risk_level, :atom do
      constraints one_of: [:info, :low, :medium, :high, :critical]
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

  actions do
    create :create do
      primary? true

      accept [
        :alert_id,
        :title,
        :description,
        :risk_level,
        :creation_time,
        :link,
        :additional_data,
        :team_id
      ]
    end

    read :read do
      primary? true
    end

    read :read_paginated do
      pagination do
        required? true
        offset? true
        countable true
        default_limit 20
      end
    end

    update :update do
      primary? true
    end

    update :update_additional_data do
      accept [
        :additional_data
      ]
    end
  end

  resource do
    plural_name :alerts
  end

  preparations do
    prepare build(load: [:team, :case])
  end
end
