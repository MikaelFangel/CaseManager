defmodule CaseManager.ContactInfos.Phone do
  use Ash.Resource,
    otp_app: :case_manager,
    domain: CaseManager.ContactInfos,
    data_layer: AshPostgres.DataLayer

  attributes do
    uuid_primary_key :id

    attribute :country_code, :string, public?: true

    attribute :phone, :string do
      allow_nil? false
      public? true
    end

    timestamps()
  end

  postgres do
    table "phone"
    repo CaseManager.Repo
  end

  actions do
    defaults [:read, :destroy, create: :*, update: :*]
  end

  relationships do
    relationships do
      many_to_many :team, CaseManager.Teams.Team do
        through CaseManager.Relationships.TeamPhone
        source_attribute_on_join_resource :phone_id
        destination_attribute_on_join_resource :team_id
      end
    end
  end
end
