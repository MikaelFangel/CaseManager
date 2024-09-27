defmodule CaseManager.AlertExternalTest do
  use CaseManager.DataCase, async: true
  use ExUnitProperties
  use Plug.Test
  alias CaseManager.Teams.Team
  alias CaseManagerWeb.AlertGenerator

  @valid_team_attrs %{
    name: "Test Team"
  }

  setup do
    {:ok, team} = Team |> Ash.Changeset.for_create(:create, @valid_team_attrs) |> Ash.create()
    {:ok, team: team}
  end

  test "valid alert attributes return a 201 OK response", %{team: team} do
    check all(alert_attr <- AlertGenerator.alert_attrs()) do
      data = %{data: %{type: "alert", attributes: alert_attr |> Map.put(:team_id, team.id)}}
      json_data = Jason.encode!(data)

      conn =
        conn(:post, "/api/json/alerts", json_data)
        |> put_req_header("accept", "application/vnd.api+json")
        |> put_req_header("content-type", "application/vnd.api+json")
        |> CaseManagerWeb.Router.call(CaseManagerWeb.Endpoint)

      assert conn.status == 201
    end
  end

  test "invalid alert attributes return a 400 OK response", %{team: team} do
    check all(alert_attr <- AlertGenerator.alert_attrs()) do
      data = %{
        data: %{
          type: "alert",
          attributes: alert_attr |> Map.put(:team_id, team.id) |> Map.put(:title, nil)
        }
      }

      json_data = Jason.encode!(data)

      conn =
        conn(:post, "/api/json/alerts", json_data)
        |> put_req_header("accept", "application/vnd.api+json")
        |> put_req_header("content-type", "application/vnd.api+json")
        |> CaseManagerWeb.Router.call(CaseManagerWeb.Endpoint)

      assert conn.status == 400
    end
  end
end
