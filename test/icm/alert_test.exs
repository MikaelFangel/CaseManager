defmodule CaseManager.ICM.AlertTest do
  use CaseManager.DataCase, async: true
  use ExUnitProperties

  import AshJsonApi.Test

  describe "CaseManager.ICM.list_alerts" do
    test "when no alerts, nothing is returned" do
      user = generate(user(role: :admin))
      assert CaseManager.ICM.list_alerts!(actor: user).results == []
    end
  end

  describe "CaseManager.ICM.get_alert_by_id" do
    test "only admin and soc users can get alerts from a team not belonging to them" do
      alert = generate(alert())

      admin = generate(user(role: :admin))
      soc_admin = generate(user(role: :soc_admin))
      soc_analyst = generate(user(role: :soc_analyst))

      team_id = generate(team(type: :customer)).id
      team_admin = generate(user(role: :team_admin, team_id: team_id))
      team_member = generate(user(role: :team_member, team_id: team_id))

      refute team_admin.team_id == alert.team_id
      refute team_member.team_id == alert.team_id
      assert CaseManager.ICM.can_get_alert_by_id?(admin, alert.id, data: alert)
      assert CaseManager.ICM.can_get_alert_by_id?(soc_admin, alert.id, data: alert)
      assert CaseManager.ICM.can_get_alert_by_id?(soc_analyst, alert.id, data: alert)
      refute CaseManager.ICM.can_get_alert_by_id?(team_admin, alert.id, data: alert)
      refute CaseManager.ICM.can_get_alert_by_id?(team_member, alert.id, data: alert)
    end

    test "team members can read their related alerts" do
      alert = generate(alert())

      team_admin = generate(user(role: :team_admin, team_id: alert.team_id))
      team_member = generate(user(role: :team_member, team_id: alert.team_id))

      assert CaseManager.ICM.can_get_alert_by_id?(team_admin, alert.id, data: alert)
      assert CaseManager.ICM.can_get_alert_by_id?(team_member, alert.id, data: alert)
    end
  end

  describe "JSON" do
    test "can create alert" do
      user = generate(user(role: :admin))
      alert = generate(alert(team_id: user.team_id))

      # Assign to variables so they can be pinned and thus work with match
      alert_id = alert.id
      creation_time = DateTime.to_iso8601(alert.creation_time)
      link = alert.link
      risk_level = Kernel.to_string(alert.risk_level)
      title = alert.title

      CaseManager.ICM
      |> post(
        "/alert",
        %{
          data: %{
            attributes: %{
              alert_id: alert.id,
              creation_time: alert.creation_time,
              link: alert.link,
              risk_level: alert.risk_level,
              team_id: alert.team_id,
              title: alert.title
            }
          }
        },
        router: CaseManagerWeb.AshJsonApiRouter,
        status: 201,
        actor: user
      )
      |> assert_data_matches(%{
        "attributes" => %{
          "alert_id" => ^alert_id,
          "creation_time" => ^creation_time,
          "link" => ^link,
          "title" => ^title,
          "risk_level" => ^risk_level
        }
      })
    end
  end

  test "can add additional data to alert" do
    user = generate(user(role: :admin))
    alert = generate(alert(team_id: user.team_id))

    conn =
      post(
        CaseManager.ICM,
        "/alert",
        %{
          data: %{
            attributes: %{
              alert_id: alert.id,
              creation_time: alert.creation_time,
              link: alert.link,
              risk_level: alert.risk_level,
              team_id: alert.team_id,
              title: alert.title
            }
          }
        },
        router: CaseManagerWeb.AshJsonApiRouter,
        status: 201,
        actor: user
      )

    %{"data" => data} = conn.resp_body
    id = Map.get(data, "id")

    CaseManager.ICM
    |> patch(
      "/alert/#{id}/additional_data",
      %{
        data: %{
          attributes: %{
            additional_data: %{
              test: "map test"
            }
          }
        }
      },
      router: CaseManagerWeb.AshJsonApiRouter,
      status: 200,
      actor: user
    )
    |> assert_data_matches(%{
      "attributes" => %{
        "additional_data" => %{"test" => "map test"}
      }
    })
  end
end
