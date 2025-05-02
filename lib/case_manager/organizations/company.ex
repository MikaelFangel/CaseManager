defmodule CaseManager.Organizations.Company do
  @moduledoc false
  use Ash.Resource, otp_app: :case_manager, domain: CaseManager.Organizations, data_layer: AshPostgres.DataLayer

  alias CaseManager.Organizations.SOC

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

    read :get_managed do
      argument :soc_id, :string

      filter expr(soc_id == ^arg(:soc_id))

      pagination offset?: true, keyset?: true, required?: false
    end

    update :update do
      primary? true
      accept :*
    end

    destroy :delete do
      primary? true
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
    belongs_to :soc, SOC do
      public? true
    end

    many_to_many :users, CaseManager.Accounts.User do
      through CaseManager.Organizations.CompanyUser
      public? true
    end

    many_to_many :soc_accesses, SOC do
      through CaseManager.Organizations.SOCCompanyAccess
      public? true
    end
  end
end
