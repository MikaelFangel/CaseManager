defmodule CaseManager.ICM.Alert do
  @moduledoc false
  use Ash.Resource,
    domain: CaseManager.ICM,
    data_layer: AshPostgres.DataLayer,
    notifiers: [Ash.Notifier.PubSub],
    extensions: [AshJsonApi.Resource],
    authorizers: [Ash.Policy.Authorizer]

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

  policies do
    policy always() do
      authorize_if actor_attribute_equals(:role, :admin)
    end
  end

  attributes do
    uuid_primary_key :id

    attribute :alert_id, :string, allow_nil?: false
    attribute :title, :string, allow_nil?: false
    attribute :description, :string
    attribute :creation_time, :utc_datetime, allow_nil?: false
    attribute :link, :string, allow_nil?: false

    attribute :risk_level, CaseManager.ICM.Enums.RiskLevel, allow_nil?: false

    attribute :additional_data, :map do
      default %{}
      sortable? false
    end

    timestamps(public?: true)
  end

  relationships do
    belongs_to :team, CaseManager.Teams.Team do
      allow_nil? false
    end

    has_many :enrichments, CaseManager.ICM.Alert.Enrichment

    many_to_many :case, CaseManager.ICM.Case do
      through CaseManager.ICM.CaseAlert
      source_attribute_on_join_resource :alert_id
      destination_attribute_on_join_resource :case_id
    end
  end

  actions do
    defaults [:read, :destroy, update: :*]

    create :create do
      description "Submit an alert."
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

    read :read_paginated do
      description "List alerts paginated."

      pagination do
        required? true
        offset? true
        countable true
        default_limit 20
      end
    end

    update :update_additional_data do
      description "Change the additional related data to the alert."

      accept [
        :additional_data
      ]
    end
  end

  resource do
    plural_name :alerts
    description "An alert or incident triggered on a third-party security product."
  end

  aggregates do
    count :case_count, :case
  end
end
