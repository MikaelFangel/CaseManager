defmodule CaseManager.Teams.Team do
  @moduledoc """
  Resource for managing teams withing the application. Teams is supposed to be an
  entity that are used to group users.
  """
  use Ash.Resource,
    domain: CaseManager.Teams,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "team"
    repo CaseManager.Repo
  end

  actions do
    create :create do
      accept [:name, :type, :ip_id, :email_id, :phone_id]
    end

    read :read do
      primary? true
    end

    read :get_by_id do
      argument :id, :uuid
      filter expr(id == ^arg(:id))
    end
  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string, allow_nil?: false
    attribute :type, :string, default: "Customer", allow_nil?: false
    attribute :ip_id, :uuid
    attribute :email_id, :uuid
    attribute :phone_id, :uuid

    timestamps()
  end

  code_interface do
    define :get_team_by_id, action: :get_by_id, args: [:id], get?: true
  end

  validations do
    validate one_of(:type, ["Customer", "MSSP"])
  end

  relationships do
    has_many :alert, CaseManager.Alerts.Alert
    has_many :case, CaseManager.Cases.Case

    many_to_many :ip, CaseManager.ContactInfos.IP do
      through CaseManager.Relationships.TeamIP
      source_attribute_on_join_resource :team_id
      destination_attribute_on_join_resource :ip_id
    end

    many_to_many :email, CaseManager.ContactInfos.Email do
      through CaseManager.Relationships.TeamEmail
      source_attribute_on_join_resource :team_id
      destination_attribute_on_join_resource :email_id
    end

    many_to_many :phone, CaseManager.ContactInfos.Phone do
      through CaseManager.Relationships.TeamPhone
      source_attribute_on_join_resource :team_id
      destination_attribute_on_join_resource :phone_id
    end
  end
end
