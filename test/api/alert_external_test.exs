defmodule CaseManager.AlertExternalTest do
  @moduledoc """
  Module that tests the external api of the application.
  """
  use CaseManager.DataCase, async: true
  use ExUnitProperties
  use Plug.Test
  alias CaseManager.Teams.Team
  alias CaseManagerWeb.AlertGenerator
  alias CaseManagerWeb.JsonGenerator
  alias CaseManagerWeb.TeamGenerator

  setup do
    [gen_team] = TeamGenerator.team_attrs() |> Enum.take(1)
    {:ok, team} = Team |> Ash.Changeset.for_create(:create, gen_team) |> Ash.create()
    {:ok, team: team}
  end

  describe "JSON API POST" do
    property "valid alert attributes return a 201 created response", %{team: team} do
      check all(alert_attr <- AlertGenerator.alert_attrs()) do
        data = %{data: %{type: "alert", attributes: alert_attr |> Map.put(:team_id, team.id)}}
        json_data = Jason.encode!(data)

        conn =
          conn(:post, "/api/json/alerts", json_data)
          |> put_req_header("accept", "application/vnd.api+json")
          |> put_req_header("content-type", "application/vnd.api+json")
          |> put_private(:phoenix_endpoint, CaseManagerWeb.Endpoint)
          |> CaseManagerWeb.Router.call(%{})

        assert conn.status == 201
      end
    end

    property "invalid alert attributes return a 400 bad request response", %{team: team} do
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
          |> put_private(:phoenix_endpoint, CaseManagerWeb.Endpoint)
          |> CaseManagerWeb.Router.call(%{})

        assert conn.status == 400
      end
    end
  end

  describe "JSON API PATCH" do
    property "valid alert update returns a 200 OK response", %{team: team} do
      check all(
              alert_attr <- AlertGenerator.alert_attrs(),
              additional_data <- JsonGenerator.json_map()
            ) do
        # Step 1: Create an alert first
        data = %{data: %{type: "alert", attributes: alert_attr |> Map.put(:team_id, team.id)}}
        json_data = Jason.encode!(data)

        conn =
          conn(:post, "/api/json/alerts", json_data)
          |> put_req_header("accept", "application/vnd.api+json")
          |> put_req_header("content-type", "application/vnd.api+json")
          |> put_private(:phoenix_endpoint, CaseManagerWeb.Endpoint)
          |> CaseManagerWeb.Router.call(%{})

        assert conn.status == 201

        # Extract the alert ID from the response
        {:ok, response_body} = Jason.decode(conn.resp_body)
        alert_id = response_body["data"]["id"]

        # Step 2: Update the alert with new attributes
        updated_data = %{data: %{type: "alert", attributes: %{additional_data: additional_data}}}
        updated_json_data = Jason.encode!(updated_data)

        update_conn =
          conn(:patch, "/api/json/alerts/#{alert_id}", updated_json_data)
          |> put_req_header("accept", "application/vnd.api+json")
          |> put_req_header("content-type", "application/vnd.api+json")
          |> put_private(:phoenix_endpoint, CaseManagerWeb.Endpoint)
          |> CaseManagerWeb.Router.call(%{})

        assert update_conn.status == 200
      end
    end

    property "invalid alert update returns a 400 bad request response", %{team: team} do
      check all(alert_attr <- AlertGenerator.alert_attrs()) do
        # Step 1: Create an alert
        data = %{data: %{type: "alert", attributes: alert_attr |> Map.put(:team_id, team.id)}}
        json_data = Jason.encode!(data)

        conn =
          conn(:post, "/api/json/alerts", json_data)
          |> put_req_header("accept", "application/vnd.api+json")
          |> put_req_header("content-type", "application/vnd.api+json")
          |> put_private(:phoenix_endpoint, CaseManagerWeb.Endpoint)
          |> CaseManagerWeb.Router.call(%{})

        assert conn.status == 201

        # Extract the alert ID
        {:ok, response_body} = Jason.decode(conn.resp_body)
        alert_id = response_body["data"]["id"]

        # Step 2: Attempt to update with an attribute you're not allowed to
        invalid_data = %{data: %{type: "alert", attributes: %{title: nil}}}
        invalid_json_data = Jason.encode!(invalid_data)

        invalid_conn =
          conn(:patch, "/api/json/alerts/#{alert_id}", invalid_json_data)
          |> put_req_header("accept", "application/vnd.api+json")
          |> put_req_header("content-type", "application/vnd.api+json")
          |> put_private(:phoenix_endpoint, CaseManagerWeb.Endpoint)
          |> CaseManagerWeb.Router.call(%{})

        assert invalid_conn.status == 400
      end
    end
  end
end
