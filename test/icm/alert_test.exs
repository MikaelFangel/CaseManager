defmodule CaseManager.ICM.AlertTest do
  use CaseManager.DataCase, async: true
  use ExUnitProperties

  describe "CaseManager.ICM.list_alerts" do
    test "when no alerts, nothing is returned" do
      user = generate(user())
      assert CaseManager.ICM.list_alerts!(actor: user).results == []
    end
  end

  describe "CaseManager.ICM.get_alert_by_id" do
    # Skipped because policies is not implemented for alerts yet.
    @tag :skip
    test "only mssp users can get alerts from a team not belonging to them" do
      alert = generate(alert())

      mssp_team = generate(team(type: :mssp))
      mssp_user = generate(user(team_id: mssp_team.id))

      customer_team = generate(team(type: :customer))
      customer_user = generate(user(team_id: customer_team.id))

      assert CaseManager.ICM.can_get_alert_by_id?(mssp_user, alert.id, data: alert)
      refute CaseManager.ICM.can_get_alert_by_id?(customer_user, alert.id, data: alert)
    end
  end
end
