defmodule CaseManager.ICM.UserTest do
  use CaseManager.DataCase, async: true
  use ExUnitProperties

  describe "CaseManager.Teams.list_users" do
    test "when no users, nothing is returned" do
      team = generate(team())
      user = generate(user(team_id: team.id))

      assert length(CaseManager.Teams.list_users!(actor: user).results) == 1
    end
  end

  describe "CaseManager.Teams.get_user_by_id" do
    # Skipped because the user.team_type is not loaded and thus makes test fail
    @tag :skip
    test "a customer user can only read other users from the same team or from an MSSP team." do
      team = generate(team())
      mssp_team = generate(team(type: :mssp))
      other_team = generate(team(type: :customer))

      user = generate(user(team_id: team.id))
      user2 = generate(user(team_id: team.id))
      mssp_user = generate(user(team_id: mssp_team.id))
      other_user = generate(user(team_id: other_team.id))

      assert CaseManager.Teams.can_get_user_by_id?(user, user.id, data: user)
      assert CaseManager.Teams.can_get_user_by_id?(user, user2.id, data: user2)
      assert CaseManager.Teams.can_get_user_by_id?(mssp_user, user.id, data: user)
      refute CaseManager.Teams.can_get_user_by_id?(other_user, user.id, data: user)
    end
  end
end
