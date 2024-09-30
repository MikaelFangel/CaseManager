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
      accept [:ip, :name, :email, :phone, :is_mssp]
    end

    read :read do
      primary? true
    end
  end

  attributes do
    uuid_primary_key :id
    attribute :ip, :string
    attribute :name, :string
    attribute :email, :string
    attribute :phone, :string

    attribute :is_mssp, :boolean do
      default false
    end

    timestamps()
  end

  relationships do
    has_many :alert, CaseManager.Alerts.Alert
    has_many :case, CaseManager.Cases.Case
  end
end
