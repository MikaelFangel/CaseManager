defmodule CaseManager.MSSPCreateTest do
  use CaseManager.DataCase, async: true

  alias CaseManager.ICM.Checks.MSSPCreate
  alias CaseManager.Teams.User

  describe "MSSPCreate.match?/3" do
    setup do
      actor_mssp = %User{team_type: :mssp}
      actor_customer = %User{team_type: :customer}
      actor_not_loaded = %User{team_type: %Ash.NotLoaded{}}

      {:ok, actor_mssp: actor_mssp, actor_customer: actor_customer, actor_not_loaded: actor_not_loaded}
    end

    test "matches when actor is part of the MSSP team", %{actor_mssp: actor} do
      assert MSSPCreate.match?(actor, %{}, []) == true
    end

    test "does not match when actor is not part of the MSSP team", %{actor_customer: actor} do
      assert MSSPCreate.match?(actor, %{}, []) == false
    end

    test "does not match when actor's team type is not loaded and not a user", %{actor_not_loaded: actor} do
      assert MSSPCreate.match?(actor, %{}, []) == false
    end

    test "does not match when actor is not a CaseManager.Teams.User" do
      assert MSSPCreate.match?("not_a_user", %{}, []) == false
    end
  end
end
