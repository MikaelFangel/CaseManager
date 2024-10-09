defmodule CaseManager.CaseInternalTest do
  @moduledoc """
  Test cases for the internal API for the case and comment resource.
  """
  use CaseManager.DataCase, async: true
  use ExUnitProperties
  alias CaseManager.Cases.{Case, Comment}
  alias CaseManager.Teams.{Team, User}
  alias CaseManagerWeb.CaseGenerator

  setup do
    {customer_team, mssp_team} = generate_team("setup")
    {eve_team, _} = generate_team("eve")

    gen_map = %{
      first_name: "Testing",
      last_name: "Testing",
      password: "12345678",
      password_confirmation: "12345678"
    }

    mssp_user_attrs =
      gen_map
      |> Map.put(:team_id, mssp_team.id)
      |> Map.put(:email, "mssp@mail.dk")

    customer_user_attrs =
      gen_map
      |> Map.put(:team_id, customer_team.id)
      |> Map.put(:email, "customer@mail.dk")

    eve_user_attrs =
      gen_map
      |> Map.put(:team_id, eve_team.id)
      |> Map.put(:email, "eve@mail.dk")

    customer_user =
      Ash.Changeset.for_create(User, :register_with_password, customer_user_attrs)
      |> Ash.create!()

    mssp_user =
      Ash.Changeset.for_create(User, :register_with_password, mssp_user_attrs) |> Ash.create!()

    eve_user =
      Ash.Changeset.for_create(User, :register_with_password, eve_user_attrs) |> Ash.create!()

    %{customer_user: customer_user, mssp_user: mssp_user, eve_user: eve_user}
  end

  defp generate_team(name) do
    customer_team =
      Ash.Changeset.for_create(Team, :create, %{name: name, type: :customer}) |> Ash.create!()

    mssp_team =
      Ash.Changeset.for_create(Team, :create, %{name: name, type: :mssp}) |> Ash.create!()

    {customer_team, mssp_team}
  end

  describe "positive test for creating cases" do
    property "only MSSP team users can create cases", %{
      customer_user: customer_user,
      mssp_user: mssp_user
    } do
      check all(case_attr <- CaseGenerator.case_attrs()) do
        nil_changeset = Case |> Ash.Changeset.for_create(:create, case_attr, actor: mssp_user)

        mssp_changeset =
          Case
          |> Ash.Changeset.for_create(
            :create,
            case_attr
            |> Map.put(:team_id, mssp_user.team_id)
            |> Map.put(:assignee_id, mssp_user.id),
            actor: mssp_user
          )

        customer_changeset =
          Case
          |> Ash.Changeset.for_create(
            :create,
            case_attr
            |> Map.put(:team_id, customer_user.team_id)
            |> Map.put(:assignee_id, customer_user.id),
            actor: customer_user
          )

        assert {:ok, _case} = mssp_changeset |> Ash.create()
        assert {:error, _case} = customer_changeset |> Ash.create()
        assert {:error, _case} = nil_changeset |> Ash.create()
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
        case =
          Case
          |> Ash.Changeset.for_create(
            :create,
            case_attr
            |> Map.put(:team_id, customer_user.team_id)
            |> Map.put(:assignee_id, mssp_user.id),
            actor: mssp_user
          )
          |> Ash.create!()

        gen_comment = %{case_id: case.id, user_id: customer_user.id, body: comment_body}
        gen_comment_negative = %{case_id: case.id, user_id: eve_user.id, body: comment_body}

        pos_changeset =
          Comment |> Ash.Changeset.for_create(:create, gen_comment, actor: customer_user)

        mssp_changeset =
          Comment |> Ash.Changeset.for_create(:create, gen_comment, actor: mssp_user)

        neg_changeset =
          Comment |> Ash.Changeset.for_create(:create, gen_comment_negative, actor: eve_user)

        refute eve_user.team_id == customer_user.team_id
        assert {:ok, _comment} = pos_changeset |> Ash.create()
        assert {:ok, _comment} = mssp_changeset |> Ash.create()
        assert {:error, _comment} = neg_changeset |> Ash.create()
      end
    end
  end
end
