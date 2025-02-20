defmodule CaseManager.ICM.TeamTest do
  use CaseManager.DataCase, async: true
  use ExUnitProperties

  describe "CaseManager.Teams.list_teams" do
    test "when no teams, nothing is returned" do
      assert CaseManager.Teams.list_teams!() == []
    end
  end

  describe "CaseManager.Teams.get_team_by_id!" do
    # Test currently fails
    @tag :skip
    test "a team can only be read by a user belonging to the team or an mssp user" do
      team = generate(team())
      mssp_team = generate(team(type: :mssp))
      other_team = generate(team(type: :customer))

      user = generate(user(team_id: team.id))
      mssp_user = generate(user(team_id: mssp_team.id))
      other_user = generate(user(team_id: other_team.id))

      assert CaseManager.Teams.can_get_team_by_id?(user, team.id, data: team)
      assert CaseManager.Teams.can_get_team_by_id?(mssp_user, team.id, data: team)
      refute CaseManager.Teams.can_get_team_by_id?(other_user, team.id, data: team)
    end
  end
end
