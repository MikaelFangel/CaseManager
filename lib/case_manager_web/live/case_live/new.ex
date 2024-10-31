defmodule CaseManagerWeb.CaseLive.New do
  use CaseManagerWeb, :live_view
  alias AshPhoenix.Form

  def mount(_params, _session, socket) do
    selected_alerts =
      CaseManager.SelectedAlerts.get_selected_alerts(socket.assigns.current_user.id)
      |> Enum.map(fn alert_id -> {alert_id, Ash.get!(CaseManager.Alerts.Alert, alert_id)} end)

    case_team_name = 
      selected_alerts 
      |> Enum.take(1) 
      |> then(fn [{_id, alert} | _xs] -> alert.team.name end)

    form =
      CaseManager.Cases.Case
      |> Form.for_create(:create,
        forms: [
          case: [
            resource: CaseManager.Cases.Case,
            create_action: :create,
            actor: socket.assigns[:current_user]
          ]
        ],
        domain: CaseManager.Cases
      )
      |> Form.add_form([:case])
      |> to_form()

      socket =
        socket
        |> assign(:menu_item, nil)
        |> assign(:current_user, socket.assigns.current_user)
        |> assign(:case_team_name, case_team_name)
        |> assign(:case_related_alerts, selected_alerts)
        |> assign(:form, form)

    # Redirect users if they try to access the page through the URL without selecting any alerts
    # else assign the selected alerts to the socket and render the page.
    case selected_alerts do
      [] -> {:ok, push_navigate(socket, to: ~p"/alerts")}
      _alerts -> {:ok, socket}
    end
  end
end
