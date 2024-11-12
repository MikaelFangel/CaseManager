defmodule CaseManager.Teams do
  @moduledoc """
  Domain that reprensents teams and their related resources.
  """
  use Ash.Domain,
    extensions: [AshAdmin.Domain]

  admin do
    show?(true)
  end

  resources do
    resource CaseManager.Teams.Team
    resource CaseManager.Teams.User
    resource CaseManager.Teams.Token
    resource CaseManager.Teams.IP
    resource CaseManager.Teams.Email
    resource CaseManager.Teams.Phone
  end
end
