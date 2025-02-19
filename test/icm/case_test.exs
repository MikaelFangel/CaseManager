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
end
