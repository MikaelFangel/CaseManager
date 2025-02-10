defmodule CaseManager.Teams do
  @moduledoc """
  Domain that reprensents teams and their related resources.
  """
  use Ash.Domain,
    extensions: [AshAdmin.Domain]

  alias CaseManager.Teams

  admin do
    show?(true)
  end

  domain do
    description """
    Resources related to a team.
    """
  end

  resources do
    resource Teams.Team do
      define :read_teams, action: :read_by_name_asc
      define :read_teams_paged, action: :page_by_name_asc
      define :add_case_to_team, args: [:case], action: :add_case
      define :add_alert_to_team, args: [:alert], action: :add_alert
    end

    resource Teams.User
    resource Teams.Token
    resource Teams.IP
    resource Teams.Email
    resource Teams.Phone
  end
end
