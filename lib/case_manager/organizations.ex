defmodule CaseManager.Organizations do
  @moduledoc false
  use Ash.Domain, otp_app: :case_manager, extensions: [AshAdmin.Domain, AshPhoenix]

  alias CaseManager.Organizations.Company

  admin do
    show? true
  end

  resources do
    resource Company do
      define :create_company, action: :create
      define :list_company, action: :read
      define :get_company, action: :read, get_by: :id
      define :update_company, action: :update
      define :delete_company, action: :delete
      define :get_managed_companies, action: :get_managed, args: [:soc_id]
    end

    resource CaseManager.Organizations.SOC do
      define :create_soc, action: :create
      define :list_soc, action: :read
      define :get_soc, action: :read, get_by: :id
      define :update_soc, action: :update
      define :delete_soc, action: :delete
      define :share_companies_with_soc, action: :share_companies, args: [:companies]
    end

    resource CaseManager.Organizations.SOCCompanyAccess
    resource CaseManager.Organizations.SOCUser
    resource CaseManager.Organizations.CompanyUser
  end
end
