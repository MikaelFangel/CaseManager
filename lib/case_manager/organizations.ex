defmodule CaseManager.Organizations do
  @moduledoc false
  use Ash.Domain, otp_app: :case_manager

  resources do
    resource CaseManager.Organizations.Company
    resource CaseManager.Organizations.SOC
    resource CaseManager.Organizations.SOCCompanyAccess
    resource CaseManager.Organizations.SOCUser
    resource CaseManager.Organizations.CompanyUser
  end
end
