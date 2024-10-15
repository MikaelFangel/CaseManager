defmodule CaseManagerWeb.CaseLive.New do
  use CaseManagerWeb, :live_view

  def mount(_params, _session, socket) do
    selected_alerts =
      CaseManager.SelectedAlerts.get_selected_alerts(socket.assigns.current_user.id)

    selected_alerts =
      Enum.map(selected_alerts, fn a -> {a, Ash.get!(CaseManager.Alerts.Alert, a)} end)

    {:ok, assign(socket, :selected_alerts, selected_alerts)}
  end
end
