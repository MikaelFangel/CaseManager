defmodule CaseManager.Organizations.SOCCompanyAccess do
  @moduledoc false
  use Ash.Resource, otp_app: :case_manager, domain: CaseManager.Organizations, data_layer: AshPostgres.DataLayer

  postgres do
    table "soc_company_accesses"
    repo(CaseManager.Repo)
  end

  actions do
    defaults [:read, :destroy, create: :*, update: :*]
  end

  attributes do
    timestamps()
  end

  relationships do
    belongs_to :soc, CaseManager.Organizations.SOC do
      primary_key? true
      allow_nil? false
      public? true
    end

    belongs_to :company, CaseManager.Organizations.Company do
      primary_key? true
      allow_nil? false
      public? true
    end
  end
end
