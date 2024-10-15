defmodule CaseManagerWeb.CaseLive.New do
  use CaseManagerWeb, :live_view

  def mount(_params, _, socket) do
    selected_alerts =
      CaseManager.SelectedAlerts.get_selected_alerts("3a174fb6-1734-4282-b5ee-3c9f210bfd0b")

    selected_alerts =
      Enum.map(selected_alerts, fn a -> {a, Ash.get!(CaseManager.Alerts.Alert, a)} end)

    {:ok, assign(socket, :selected_alerts, selected_alerts)}
  end
end
