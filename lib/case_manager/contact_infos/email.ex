defmodule CaseManager.ContactInfos.Email do
  @moduledoc """
  Resource that represents emails. This resources is different from the email used for authentication.
  """
  use Ash.Resource,
    otp_app: :case_manager,
    domain: CaseManager.ContactInfos,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "email"
    repo CaseManager.Repo
  end

  actions do
    defaults [:read, :destroy, create: :*, update: :*]
  end

  attributes do
    uuid_primary_key :id

    attribute :email, :string, allow_nil?: false, public?: true

    timestamps()
  end

  relationships do
    relationships do
      many_to_many :team, CaseManager.Teams.Team do
        through CaseManager.Relationships.TeamEmail
        source_attribute_on_join_resource :email_id
        destination_attribute_on_join_resource :team_id
      end
    end
  end
end
