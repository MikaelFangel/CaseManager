defmodule CaseManager.Teams do
  @moduledoc """
  Domain that reprensents teams and their related resources.
  """
  use Ash.Domain

  resources do
    resource CaseManager.Teams.Team
    resource CaseManager.Teams.User
    resource CaseManager.Relationships.TeamIP
    resource CaseManager.Relationships.TeamEmail
    resource CaseManager.Relationships.TeamPhone
  end
end
