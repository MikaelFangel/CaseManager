defmodule CaseManager.Organizations.SOCCompanyAccess do
  @moduledoc false
  use Ash.Resource, otp_app: :case_manager, domain: CaseManager.Organizations, data_layer: AshPostgres.DataLayer

  postgres do
    table "soc_company_accesses"
    repo(CaseManager.Repo)
  end

  attributes do
    uuid_primary_key :id

    timestamps()
  end

  relationships do
    belongs_to :soc, CaseManager.Organizations.SOC do
      allow_nil? false
    end

    belongs_to :company, CaseManager.Organizations.Company do
      allow_nil? false
    end
  end
end
