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
    test "a case can only be read by an mssp user or one related to the same team" do
      mssp_user = generate(user(role: StreamData.one_of([:soc_admin, :soc_analyst, :service_account])))

      customer_team = generate(team(type: :customer))
      customer_user = generate(user(team_id: customer_team.id, role: StreamData.one_of([:team_admin, :team_member])))

      other_team = generate(team(type: :customer))
      other_user = generate(user(team_id: other_team.id, role: StreamData.one_of([:team_admin, :team_member])))

      case = generate(case(team_id: customer_team.id, escalated: true))

      assert customer_user.team_id == case.team_id
      refute other_user.team_id == case.team_id
      assert CaseManager.ICM.can_get_case_by_id?(mssp_user, case.id, data: case)
      assert CaseManager.ICM.can_get_case_by_id?(customer_user, case.id, data: case)
      refute CaseManager.ICM.can_get_case_by_id?(other_user, case.id, data: case)
    end
  end

  describe "CaseManager.ICM.view_case" do
    @tag :skip
    # Skipped because updating a relationship is not atomic and thus causes a racecondition
    test "view a case updates the last view aggregate" do
      case = generate(case())
      user = generate(user(team_id: case.team_id))

      case = Ash.load!(case, :last_viewed, actor: user)
      refute case.last_viewed

      CaseManager.ICM.view_case(case, DateTime.utc_now(), actor: user)
      case = Ash.load!(case, :last_viewed, actor: user)
      assert case.last_viewed != nil
    end

    @tag :skip
    # Skipped because updating a relationship is not atomic and thus causes a racecondition
    test "a case is viewed when created by a user and new when not" do
      case = generate(case())
      user = [team_id: case.team_id] |> user() |> generate()
      other = generate(user())

      CaseManager.ICM.view_case(case, DateTime.utc_now(), actor: user)

      case = Ash.load!(case, [:updated_since_last?, :last_viewed, :views], actor: user)
      refute case.updated_since_last?

      case = Ash.load!(case, [:updated_since_last?, :last_viewed, :views], actor: other)
      assert case.updated_since_last?
    end
  end
end
