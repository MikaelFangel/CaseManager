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
      accept [:name, :type]
    end

    read :read do
      primary? true
    end
  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string, allow_nil?: false

    attribute :type, :atom do
      default :customer
      allow_nil? false
      constraints one_of: [:customer, :mssp]
    end

    timestamps()
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
