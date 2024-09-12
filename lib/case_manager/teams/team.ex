defmodule CaseManager.Teams.Team do
  use Ash.Resource,
    domain: CaseManager.Teams,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "teams"
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
    attribute :is_mssp, :boolean

    timestamps()
  end
end
