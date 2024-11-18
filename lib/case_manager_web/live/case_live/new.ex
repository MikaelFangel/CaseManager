defmodule CaseManagerWeb.CaseLive.New do
  use CaseManagerWeb, :live_view
  alias AshPhoenix.Form

  def mount(_params, _session, socket) do
    selected_alerts =
      socket.assigns.current_user.id
      |> CaseManager.SelectedAlerts.get_selected_alerts()
      |> Enum.map(fn alert_id -> {alert_id, Ash.get!(CaseManager.Alerts.Alert, alert_id)} end)

    # Redirect users if they try to access the page through the URL without selecting any alerts
    # else assign the selected alerts to the socket and render the page.
    case selected_alerts do
      [] ->
        {:ok, push_navigate(socket, to: ~p"/alerts")}

      _alerts ->
        first_team = fn
          [{_id, alert} | _rest] -> alert.team
          _empty -> nil
        end

        form =
          selected_alerts
          |> first_team.()
          |> Form.for_update(:add_case,
            forms: [auto?: true],
            actor: socket.assigns[:current_user]
          )
          |> to_form()

        socket =
          socket
          |> assign(:menu_item, nil)
          |> assign(:current_user, socket.assigns.current_user)
          |> assign(:team_name, first_team.(selected_alerts).name)
          |> assign(:related_alerts, selected_alerts)
          |> assign(:form, form)

        {:ok, socket, layout: {CaseManagerWeb.Layouts, :app_m0}}
    end
  end
end
