defmodule CaseManager.ICM.Case.View do
  @moduledoc false
  use Ash.Resource,
    otp_app: :case_manager,
    domain: CaseManager.ICM,
    data_layer: AshPostgres.DataLayer,
    authorizers: [Ash.Policy.Authorizer]

  postgres do
    table "views"
    repo CaseManager.Repo
  end

  policies do
    policy action_type([:read, :destroy, :update]) do
      authorize_if relates_to_actor_via(:user)
    end

    policy action_type(:create) do
      authorize_if always()
    end
  end

  attributes do
    uuid_primary_key :id

    attribute :time, :utc_datetime, allow_nil?: false
  end

  relationships do
    belongs_to :user, CaseManager.Teams.User, allow_nil?: false

    many_to_many :cases, CaseManager.ICM.Case do
      through CaseManager.ICM.CaseView
      source_attribute_on_join_resource :view_id
      destination_attribute_on_join_resource :case_id
    end
  end

  actions do
    defaults [:destroy, update: :*]

    read :read do
      primary? true
    end

    create :create do
      accept [:time]
      primary? true
      change relate_actor(:user)
    end
  end

  resource do
    description "A view timestamp of a case."
  end
end
