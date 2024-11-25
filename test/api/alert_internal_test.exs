defmodule CaseManager.Alerts.AlertInternalTest do
  @moduledoc """
  Test cases for the internal api for the alert resource.
  """
  use CaseManager.DataCase, async: true
  use ExUnitProperties

  alias CaseManager.Alerts.Alert
  alias CaseManager.Teams.Team
  alias CaseManagerWeb.AlertGenerator
  alias CaseManagerWeb.TeamGenerator

  setup do
    [gen_team] = Enum.take(TeamGenerator.team_attrs(), 1)
    {:ok, team} = Team |> Ash.Changeset.for_create(:create, gen_team) |> Ash.create()
    {:ok, team: team}
  end

  describe "postive tests for creating alerts" do
    property "creates an alert with a valid team_id", %{team: team} do
      check all(alert_attrs <- AlertGenerator.alert_attrs()) do
        changeset = Ash.Changeset.for_create(Alert, :create, Map.put(alert_attrs, :team_id, team.id))

        assert {:ok, _alert} = Ash.create(changeset)
      end
    end
  end

  describe "negative tests for creating alerts" do
    property "fails to create an alert with missing required fields", %{team: team} do
      changeset = Ash.Changeset.for_create(Alert, :create, %{team_id: team.id})

      assert {:error, _changeset} = Ash.create(changeset)
    end

    property "fails to create an alert with an invalid risk_level", %{team: team} do
      check all(
              alert_attrs <- AlertGenerator.alert_attrs(),
              risk_level <-
                :alphanumeric
                |> string()
                |> filter(&(&1 not in AlertGenerator.valid_risk_levels()))
            ) do
        changeset =
          Ash.Changeset.for_create(
            Alert,
            :create,
            alert_attrs |> Map.put(:team_id, team.id) |> Map.put(:risk_level, risk_level)
          )

        assert {:error, _changeset} = Ash.create(changeset)
      end
    end

    property "fails to create an alert with an invalid team_id" do
      check all(alert_attrs <- AlertGenerator.alert_attrs()) do
        changeset = Ash.Changeset.for_create(Alert, :create, Map.put(alert_attrs, :team_id, Ecto.UUID.generate()))

        assert {:error, _changeset} = Ash.create(changeset)
      end
    end
  end
end
