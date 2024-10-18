defmodule CaseManagerWeb.CaseLive.New do
  use CaseManagerWeb, :live_view

  def mount(_params, _session, socket) do
    selected_alerts =
      CaseManager.SelectedAlerts.get_selected_alerts(socket.assigns.current_user.id)
      |> Enum.map(fn alert_id -> {alert_id, Ash.get!(CaseManager.Alerts.Alert, alert_id)} end)

    # Redirect users if they try to access the page through the URL without selecting any alerts
    # else assign the selected alerts to the socket and render the page.
    case selected_alerts do
      [] ->
        {:ok, push_navigate(socket, to: ~p"/alerts")}

      _alerts ->
        {:ok,
         assign(socket, :selected_alerts, selected_alerts)
         |> assign(current_user: socket.assigns.current_user)}
    end
  end
end
