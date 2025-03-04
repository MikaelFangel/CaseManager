defmodule CaseManage.ICM.Alert.EnrichmentTest do
  use CaseManager.DataCase, async: true
  use ExUnitProperties

  describe "CaseManager.ICM.list_enrichments" do
    test "when no enrichments, nothing is returned" do
      user = generate(user(role: :admin))
      assert CaseManager.ICM.list_enrichments!(actor: user) == []
    end
  end
end
