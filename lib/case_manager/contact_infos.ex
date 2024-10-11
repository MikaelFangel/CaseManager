defmodule CaseManager.ContactInfos do
  @moduledoc """
  Domain for representing contact informations.
  """
  use Ash.Domain

  resources do
    resource CaseManager.ContactInfos.IP
    resource CaseManager.ContactInfos.Email
    resource CaseManager.ContactInfos.Phone
    resource CaseManager.Relationships.TeamIP
    resource CaseManager.Relationships.TeamEmail
    resource CaseManager.Relationships.TeamPhone
  end
end
