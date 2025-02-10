defmodule CaseManager.CaseInternalTest do
  @moduledoc """
  Test cases for the internal API for the case and comment resource.
  """
  use CaseManager.DataCase, async: true
  use ExUnitProperties

  alias CaseManager.ICM
  alias CaseManager.Teams.Team
  alias CaseManager.Teams.User
  alias CaseManagerWeb.CaseGenerator

  setup do
    {customer_team, mssp_team, eve_team} = generate_teams()

    user_attrs = %{
      first_name: "Testing",
      last_name: "Testing",
      password: "12345678",
      password_confirmation: "12345678",
      role: :analyst
    }

    customer_user = create_user(user_attrs, customer_team.id, "customer@mail.dk")
    mssp_user = create_user(user_attrs, mssp_team.id, "mssp@mail.dk")
    eve_user = create_user(user_attrs, eve_team.id, "eve@mail.dk")

    %{customer_user: customer_user, mssp_user: mssp_user, eve_user: eve_user}
  end

  defp generate_teams do
    customer_team = create_team("customer", :customer)
    mssp_team = create_team("mssp", :mssp)
    eve_team = create_team("eve", :customer)

    {customer_team, mssp_team, eve_team}
  end

  defp create_team(name, type) do
    Team
    |> Ash.Changeset.for_create(:create, %{name: name, type: type})
    |> Ash.create!()
  end

  defp create_user(attrs, team_id, email) do
    attrs =
      attrs
      |> Map.put(:team_id, team_id)
      |> Map.put(:email, email)

    User
    |> Ash.Changeset.for_create(:register_with_password, attrs)
    |> Ash.create!()
  end

  describe "positive test for creating cases" do
    property "only MSSP team users can create cases", %{
      customer_user: customer_user,
      mssp_user: mssp_user
    } do
      check all(case_attr <- CaseGenerator.case_attrs()) do
        team = Ash.load!(customer_user, :team).team

        assert {:ok, _case} = CaseManager.Teams.add_case_to_team(team, case_attr, actor: mssp_user)
        assert {:error, _case} = CaseManager.Teams.add_case_to_team(team, case_attr, actor: customer_user)
        assert {:error, _case} = CaseManager.Teams.add_case_to_team(team, %{}, actor: mssp_user)
      end
    end
  end

  describe "positive tests for relationships" do
    property "only user where their team_id is the same as the case team_id can comment", %{
      customer_user: customer_user,
      mssp_user: mssp_user,
      eve_user: eve_user
    } do
      check all(
              case_attr <- CaseGenerator.case_attrs(),
              comment_body <- StreamData.string(:utf8, min_length: 1)
            ) do
        team = CaseManager.Teams.add_case_to_team!(Ash.load!(customer_user, :team).team, case_attr, actor: mssp_user)

        [case] = team.case

        refute eve_user.team_id == customer_user.team_id
        assert {:ok, _comment} = ICM.add_comment_to_case(case, comment_body, actor: customer_user)
        assert {:ok, _comment} = ICM.add_comment_to_case(case, comment_body, actor: mssp_user)
        assert {:error, _comment} = ICM.add_comment_to_case(case, comment_body, actor: eve_user)
      end
    end
  end
end
