defmodule CaseManager.ICM.Alert.Enrichment do
  @moduledoc false
  use Ash.Resource,
    domain: CaseManager.ICM,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshJsonApi.Resource],
    authorizers: [Ash.Policy.Authorizer]

  alias CaseManager.ICM.Alert

  postgres do
    table "alert_enrichments"
    repo CaseManager.Repo

    references do
      reference :alert, on_delete: :delete, on_update: :update, name: "alert_to_enrichment_fkey"
    end
  end

  policies do
    bypass actor_attribute_equals(:role, :admin) do
      authorize_if always()
    end

    policy always() do
      forbid_unless actor_attribute_equals(:archived_at, nil)
      authorize_if accessing_from(Alert, :alert)
      authorize_if actor_attribute_equals(:role, :soc_admin)
      authorize_if actor_attribute_equals(:role, :soc_analyst)
      authorize_if actor_attribute_equals(:role, :service_account)
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
    belongs_to :alert, Alert do
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
