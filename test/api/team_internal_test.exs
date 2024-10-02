defmodule CaseManager.TeamInternalTest do
  use CaseManager.DataCase, async: true
  use ExUnitProperties
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
end
