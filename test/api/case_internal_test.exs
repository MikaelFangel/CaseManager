defmodule CaseManager.CaseInternalTest do
  @moduledoc """
  Test cases for the internal API for the case and comment resource.
  """
  use CaseManager.DataCase, async: true
  use ExUnitProperties
  alias CaseManager.Cases.{Case, Comment}
  alias CaseManager.ContactInfos.Email
  alias CaseManager.Teams.{Team, User}
  alias CaseManagerWeb.{CaseGenerator, UserGenerator}

  defp generate_team(name) do
    customer_team =
      Ash.Changeset.for_create(Team, :create, %{name: name, type: "Customer"}) |> Ash.create!()

    mssp_team =
      Ash.Changeset.for_create(Team, :create, %{name: name, type: "MSSP"}) |> Ash.create!()

    {customer_team, mssp_team}
  end

  defp generate_email(email_gen) do
    Ash.Changeset.for_create(Email, :create, %{email: email_gen}) |> Ash.create!()
  end

  defp generate_users(email, customer_team, mssp_team, user_gen) do
    mssp_user_attrs = Map.put(user_gen, :email_id, email.id) |> Map.put(:team_id, mssp_team.id)

    customer_user_attrs =
      Map.put(user_gen, :email_id, email.id) |> Map.put(:team_id, customer_team.id)

    customer_user = Ash.Changeset.for_create(User, :create, customer_user_attrs) |> Ash.create!()
    mssp_user = Ash.Changeset.for_create(User, :create, mssp_user_attrs) |> Ash.create!()

    {customer_user, mssp_user}
  end

  describe "positive test for creating cases" do
    property "only MSSP team users can create cases" do
      check all(
              team_name <- StreamData.string(:printable, min_length: 1),
              email_gen <- StreamData.string(:printable, min_length: 1),
              user_gen <- UserGenerator.user_attrs(),
              case_attr <- CaseGenerator.case_attrs()
            ) do
        {customer_team, mssp_team} = generate_team(team_name)
        email = generate_email(email_gen)
        {customer_user, mssp_user} = generate_users(email, customer_team, mssp_team, user_gen)

        nil_changeset = Case |> Ash.Changeset.for_create(:create, case_attr, actor: mssp_user)

        mssp_changeset =
          Case
          |> Ash.Changeset.for_create(
            :create,
            case_attr
            |> Map.put(:team_id, mssp_team.id)
            |> Map.put(:assignee_id, mssp_user.id),
            actor: mssp_user
          )

        customer_changeset =
          Case
          |> Ash.Changeset.for_create(
            :create,
            case_attr
            |> Map.put(:team_id, customer_team.id)
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
    property "only user where their team_id is the same as the case team_id can comment" do
      check all(
              team_name <- StreamData.string(:printable, min_length: 1),
              email_gen <- StreamData.string(:printable, min_length: 1),
              user_gen <- UserGenerator.user_attrs(),
              case_attr <- CaseGenerator.case_attrs(),
              comment_body <- StreamData.string(:utf8, min_length: 1)
            ) do
        {customer_team, mssp_team} = generate_team(team_name)
        {eve_customer_team, eve_mssp_team} = generate_team(team_name)
        email = generate_email(email_gen)
        {customer_user, mssp_user} = generate_users(email, customer_team, mssp_team, user_gen)
        {eve_user, _} = generate_users(email, eve_customer_team, eve_mssp_team, user_gen)

        case =
          Case
          |> Ash.Changeset.for_create(
            :create,
            case_attr
            |> Map.put(:team_id, customer_team.id)
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
