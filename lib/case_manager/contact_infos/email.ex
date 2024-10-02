defmodule CaseManager.ContactInfos.Email do
  use Ash.Resource,
    otp_app: :case_manager,
    domain: CaseManager.ContactInfos,
    data_layer: AshPostgres.DataLayer

  attributes do
    uuid_primary_key :id

    attribute :email, :string do
      allow_nil? false
      public? true
    end

    timestamps()
  end

  postgres do
    table "email"
    repo CaseManager.Repo
  end

  actions do
    defaults [:read, :destroy, create: :*, update: :*]
  end

  relationships do
    belongs_to :user, CaseManager.Teams.User

    relationships do
      many_to_many :team, CaseManager.Teams.Team do
        through CaseManager.Relationships.TeamEmail
        source_attribute_on_join_resource :email_id
        destination_attribute_on_join_resource :team_id
      end
    end
  end
end
