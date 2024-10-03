defmodule CaseManager.CaseInternalTest do
  @moduledoc """
  Test cases for the internal api for the the case and comment resource.
  """
  use CaseManager.DataCase, async: true
  use ExUnitProperties
  alias CaseManager.Alerts.Alert
  alias CaseManager.Cases.{Case, Comment}
  alias CaseManager.ContactInfos.Email
  alias CaseManager.Teams.{Team, User}
  alias CaseManagerWeb.{CaseGenerator, UserGenerator}

  setup do
    # Generate team data
    team_gen =
      gen all(name <- StreamData.string(:printable, min_length: 1)) do
        {%{name: name, type: "Customer"}, %{name: name, type: "MSSP"}}
      end

    # Take one generated team pair
    [{customer_gen_team, mssp_gen_team}] = Enum.take(team_gen, 1)
    [{second_gen_team, _}] = Enum.take(team_gen, 1)

    # Create customer and MSSP teams
    customer_team = Ash.Changeset.for_create(Team, :create, customer_gen_team) |> Ash.create!()
    mssp_team = Ash.Changeset.for_create(Team, :create, mssp_gen_team) |> Ash.create!()
    second_team = Ash.Changeset.for_create(Team, :create, second_gen_team) |> Ash.create!()

    # Generate email data
    [email_gen] = Enum.take(StreamData.string(:printable, min_length: 1), 1)
    email = Ash.Changeset.for_create(Email, :create, %{email: email_gen}) |> Ash.create!()

    # Generate user data
    [user_gen] = Enum.take(UserGenerator.user_attrs(), 1)
    mssp_user_attrs = Map.put(user_gen, :email_id, email.id) |> Map.put(:team_id, mssp_team.id)

    customer_user_attrs =
      Map.put(user_gen, :email_id, email.id) |> Map.put(:team_id, customer_team.id)

    second_customer_user_attrs =
      Map.put(user_gen, :email_id, email.id) |> Map.put(:team_id, customer_team.id)

    customer_user = Ash.Changeset.for_create(User, :create, customer_user_attrs) |> Ash.create!()
    mssp_user = Ash.Changeset.for_create(User, :create, mssp_user_attrs) |> Ash.create!()

    second_user =
      Ash.Changeset.for_create(User, :create, second_customer_user_attrs) |> Ash.create!()

    # Return created entities
    %{
      customer: customer_team,
      mssp: mssp_team,
      mssp_user: mssp_user,
      customer_user: customer_user,
      second_customer_user: second_user
    }
  end

  describe "positive test for creating cases" do
    property "only MSSP team users can create cases", %{
      customer: customer_team,
      mssp: mssp_team,
      mssp_user: mssp_user,
      customer_user: customer_user
    } do
      check all(case_attr <- CaseGenerator.case_attrs()) do
        nil_changeset =
          Case
          |> Ash.Changeset.for_create(:create, case_attr)

        mssp_changeset =
          Case
          |> Ash.Changeset.for_create(
            :create,
            case_attr
            |> Map.put(:team_id, mssp_team.id)
            |> Map.put(:assignee_id, mssp_user.id)
          )

        customer_changeset =
          Case
          |> Ash.Changeset.for_create(
            :create,
            case_attr
            |> Map.put(:team_id, customer_team.id)
            |> Map.put(:assignee_id, customer_user.id)
          )

        assert {:ok, _case} = mssp_changeset |> Ash.create()
        assert {:error, _case} = customer_changeset |> Ash.create()
        assert {:error, _case} = nil_changeset |> Ash.create()
      end
    end
  end

  describe "negative tests for creating cases" do
  end

  describe "positive tests for relationships" do
    property "only user where their team_id is the same as the case team_id can comment", %{
      customer: customer_team,
      mssp: mssp_team,
      customer_user: customer_user,
      mssp_user: mssp_user,
      second_customer_user: second_user
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
            |> Map.put(:team_id, customer_team.id)
            |> Map.put(:assignee_id, mssp_user.id)
          )
          |> Ash.create!()

        gen_comment = %{case_id: case.id, user_id: customer_user.id, body: comment_body}
        gen_comment_negative = %{case_id: case.id, user_id: second_user.id, body: comment_body}

        pos_changeset =
          Comment |> Ash.Changeset.for_create(:create, gen_comment)

        neg_changeset =
          Comment
          |> Ash.Changeset.for_create(:create, gen_comment_negative)

        assert case.team_id == customer_user.team_id

        assert {:ok, _comment} = pos_changeset |> Ash.create()

        assert {:errror, _comment} = neg_changeset |> Ash.create()
      end
    end
  end

  describe "negative tests for relationships" do
  end
end
