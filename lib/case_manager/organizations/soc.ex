defmodule CaseManager.Organizations.SOC do
  @moduledoc false
  use Ash.Resource, otp_app: :case_manager, domain: CaseManager.Organizations, data_layer: AshPostgres.DataLayer

  postgres do
    table "socs"
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

    read :search do
      argument :query, :ci_string do
        constraints allow_empty?: true
        default ""
      end

      filter expr(contains(name, ^arg(:query)))

      pagination offset?: true, keyset?: true, required?: false
    end

    update :update do
      primary? true
    end

    update :share_companies do
      require_atomic? false
      argument :companies, {:array, :string}

      change manage_relationship(:companies, :company_accesses, type: :append)
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
      through CaseManager.Organizations.SOCUser
      public? true
    end

    many_to_many :company_accesses, CaseManager.Organizations.Company do
      through CaseManager.Organizations.SOCCompanyAccess
      public? true
    end
  end
end
