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
    resource CaseManager.Teams.Team do
      define :read_teams, action: :read_by_name_asc
      define :read_teams_paged, action: :page_by_name_asc
      define :add_case_to_team, args: [:case], action: :add_case
      define :add_alert_to_team, args: [:alert], action: :add_alert
    end

    resource CaseManager.Teams.User
    resource CaseManager.Teams.Token
    resource CaseManager.Teams.IP
    resource CaseManager.Teams.Email
    resource CaseManager.Teams.Phone
  end
end
