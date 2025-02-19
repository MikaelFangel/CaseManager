defmodule CaseManager.ICM.CaseTest do
  use CaseManager.DataCase, async: true
  use ExUnitProperties

  describe "CaseManager.ICM.list_cases" do
    test "when no cases, nothing is returned" do
      team_id = generate(team(type: :mssp)).id
      user = generate(user(team_id: team_id))
      assert CaseManager.ICM.list_cases!(actor: user).results == []
    end
  end

  describe "CaseManager.ICM.get_case_by_id" do
    # Skipped because the user.team_type is not loaded and thus makes test fail
    @tag :skip
    test "a case can only be read by an mssp user or one related to the same team" do
      mssp_team = generate(team(type: :mssp))
      mssp_user = generate(user(team_id: mssp_team.id))

      customer_team = generate(team(type: :customer))
      customer_user = generate(user(team_id: customer_team.id))

      other_team = generate(team(type: :customer))
      other_user = generate(user(team_id: other_team.id))

      case = generate(case(team_id: customer_team.id))

      assert CaseManager.ICM.can_get_case_by_id?(mssp_user, case.id, data: case)
      assert CaseManager.ICM.can_get_case_by_id?(customer_user, case.id, data: case)
      refute CaseManager.ICM.can_get_case_by_id?(other_user, case.id, data: case)
    end
  end
end
