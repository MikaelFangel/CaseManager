defmodule CaseManager.Organizations.Company do
  @moduledoc false
  use Ash.Resource, otp_app: :case_manager, domain: CaseManager.Organizations, data_layer: AshPostgres.DataLayer

  postgres do
    table "companies"
    repo(CaseManager.Repo)
  end

  actions do
    create :create do
      primary? true

      accept :*
    end

    read :read do
      primary? true

      pagination offset?: true, keyset?: true, required?: false
    end

    update :update do
      primary? true
    end

    destroy :delete do
    end
  end

  attributes do
    uuid_primary_key :id

    attribute :name, :string do
      allow_nil? false
      public? true
    end

    timestamps()
  end

  relationships do
    many_to_many :users, CaseManager.Accounts.User do
      through CaseManager.Organizations.CompanyUser
      public? true
    end
  end
end
