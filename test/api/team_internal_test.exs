defmodule CaseManager.TeamInternalTest do
  use CaseManager.DataCase, async: true
  use ExUnitProperties
  alias CaseManager.ContactInfos.Email
  alias CaseManager.Relationships.TeamEmail
  alias CaseManager.Teams.Team
  alias CaseManagerWeb.TeamGenerator

  describe "postive tests for creating teams" do
    property "teams with only a name and a type is valid" do
      check all(team_attr <- TeamGenerator.team_attrs()) do
        changeset =
          Team
          |> Ash.Changeset.for_create(:create, team_attr)

        assert {:ok, _team} = Ash.create(changeset)
      end
    end
  end

  describe "negative tests for creating teams" do
    property "fails to create a team without any type or any name" do
      check all(
              team_attr <- TeamGenerator.team_attrs(),
              team_attr_type_nil <-
                StreamData.one_of([
                  StreamData.constant(team_attr |> Map.put(:type, nil)),
                  StreamData.constant(team_attr |> Map.put(:name, nil)),
                  StreamData.constant(team_attr |> Map.put(:type, nil) |> Map.put(:name, nil))
                ])
            ) do
        changeset =
          Team
          |> Ash.Changeset.for_create(:create, team_attr_type_nil)

        assert {:error, _team} = Ash.create(changeset)
      end
    end
  end

  describe "postive relationship test for teams" do
    property "teams can have 0 or more email relationships" do
      check all(
              team_attr <- TeamGenerator.team_attrs(),
              emails <-
                StreamData.list_of(StreamData.string(:printable, min_length: 1), min_length: 1)
            ) do
        team = Team |> Ash.Changeset.for_create(:create, team_attr) |> Ash.create!()

        email_ids =
          emails
          |> Enum.map(fn gen_mail ->
            email =
              Email |> Ash.Changeset.for_create(:create, %{email: gen_mail}) |> Ash.create!()

            TeamEmail
            |> Ash.Changeset.for_create(:create, %{team_id: team.id, email_id: email.id})
            |> Ash.create!()

            email.id
          end)

        team_with_email = Ash.load!(team, :email)
        assert length(team_with_email.email) === length(emails)
        assert Enum.sort(email_ids) === team_with_email.email |> Enum.map(& &1.id) |> Enum.sort()
      end
    end
  end

  describe "negative relationship test for teams" do
    property "fails to create relationship to emails that doesn't exsist" do
      check all(
              team_attr <- TeamGenerator.team_attrs(),
              invalid_email_uuid <- StreamData.constant(Ecto.UUID.generate())
            ) do
        team = Team |> Ash.Changeset.for_create(:create, team_attr) |> Ash.create!()

        assert {:error, _relation} =
                 TeamEmail
                 |> Ash.Changeset.for_create(:create, %{
                   team_id: team.id,
                   email_id: invalid_email_uuid
                 })
                 |> Ash.create()
      end
    end
  end
end
