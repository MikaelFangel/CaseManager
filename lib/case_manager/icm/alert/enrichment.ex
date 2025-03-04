defmodule CaseManager.ICM.Alert.Enrichment do
  @moduledoc false
  use Ash.Resource,
    domain: CaseManager.ICM,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshJsonApi.Resource],
    authorizers: [Ash.Policy.Authorizer]

  postgres do
    table "alert_enrichments"
    repo CaseManager.Repo

    references do
      reference :alert, on_delete: :delete, on_update: :update, name: "alert_to_enrichment_fkey"
    end
  end

  policies do
    policy always() do
      authorize_if actor_attribute_equals(:role, :admin)
    end
  end

  attributes do
    uuid_primary_key :id

    attribute :name, :string, allow_nil?: false
    attribute :source, :string
    attribute :summary, :string, allow_nil?: false
    attribute :data, :map

    timestamps()
  end

  relationships do
    belongs_to :alert, CaseManager.ICM.Alert do
      allow_nil? false
    end
  end

  actions do
    defaults [:read, :destroy]

    create :create do
      primary? true

      accept [
        :name,
        :summary,
        :source,
        :data,
        :alert_id
      ]
    end

    update :update do
      primary? true

      accept [
        :name,
        :summary,
        :source,
        :data,
        :alert_id
      ]
    end
  end

  resource do
    description "Enrichment correlated to an alert."
  end
end
