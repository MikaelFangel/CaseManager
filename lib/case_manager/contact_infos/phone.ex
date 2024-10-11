defmodule CaseManager.ContactInfos.Phone do
  @moduledoc """
  Resource that represents a phone number.
  """
  use Ash.Resource,
    otp_app: :case_manager,
    domain: CaseManager.ContactInfos,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "phone"
    repo CaseManager.Repo
  end

  actions do
    defaults [:read, :destroy, create: :*, update: :*]
  end

  attributes do
    uuid_primary_key :id

    attribute :country_code, :string, public?: true
    attribute :phone, :string, allow_nil?: false, public?: true

    timestamps()
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
