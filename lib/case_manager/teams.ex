defmodule CaseManager.Teams do
  @moduledoc """
  Domain that reprensents teams and their related resources.
  """
  use Ash.Domain,
    extensions: [AshAdmin.Domain, AshPhoenix]

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
      define :add_team, action: :create
      define :get_team_by_id, action: :read, get_by: :id
      define :list_teams, action: :read, default_options: [query: [sort_input: "name"]]
      define :list_teams_paged, action: :read_paged, default_options: [query: [sort_input: "name"]]
      define :add_case_to_team, args: [:case], action: :add_case
      define :add_alert_to_team, args: [:alert], action: :add_alert
    end

    resource Teams.User do
      define :register_user, action: :register_with_password
      define :get_user_by_id, action: :read_paged, get_by: :id
      define :edit_user, action: :update

      define :list_users,
        action: :read_paged,
        default_options: [query: [sort_input: "full_name", load: [:full_name, :team]]]
    end

    resource Teams.Token
    resource Teams.IP
    resource Teams.Email
    resource Teams.Phone
  end
end
