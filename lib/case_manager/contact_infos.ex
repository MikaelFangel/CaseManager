defmodule CaseManager.ContactInfos do
  use Ash.Domain

  resources do
    resource CaseManager.ContactInfos.IP
    resource CaseManager.ContactInfos.Email
    resource CaseManager.ContactInfos.Phone
  end
end
