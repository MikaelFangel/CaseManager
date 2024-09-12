defmodule CaseManager.Alerts.AlertTest do
  use CaseManager.DataCase
  alias CaseManager.Alerts.Alert
  alias CaseManager.Teams.Team

  @valid_team_attrs %{
    name: "Test Team"
  }
  @valid_alert_attrs %{
    alert_id: "12345678",
    title: "Test Alert",
    risk_level: "High",
    link: "http://example"
  }

  setup do
    {:ok, team} = Team |> Ash.Changeset.for_create(:create, @valid_team_attrs) |> Ash.create()
    {:ok, team: team}
  end

  test "creates an alert with a valid team_id", %{team: team} do
    changeset =
      Alert
      |> Ash.Changeset.for_create(:create, Map.put(@valid_alert_attrs, :team_id, team.id))

    assert {:ok, _alert} = Ash.create(changeset)
  end

  test "fails to create an alert with missing required fields", %{team: team} do
    changeset =
      Alert
      |> Ash.Changeset.for_create(:create, %{
        team_id: team.id
      })

    assert {:error, _changeset} = Ash.create(changeset)
  end

  test "fails to create an alert with an invalid team_id" do
    changeset =
      Alert
      |> Ash.Changeset.for_create(
        :create,
        Map.put(@valid_alert_attrs, :team_id, Ecto.UUID.generate())
      )

    assert {:error, _changeset} = Ash.create(changeset)
  end
end
