defmodule CaseManager.Organizations do
  @moduledoc false
  use Ash.Domain, otp_app: :case_manager

  resources do
    resource CaseManager.Organizations.Company do
      define :create_company, action: :create
      define :list_company, action: :read
      define :get_company, action: :read, get_by: :id
      define :update_company, action: :update
      define :delete_company, action: :delete
    end

    resource CaseManager.Organizations.SOC
    resource CaseManager.Organizations.SOCCompanyAccess
    resource CaseManager.Organizations.SOCUser
    resource CaseManager.Organizations.CompanyUser
  end
end
