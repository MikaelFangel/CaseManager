defmodule CaseManagerWeb.AlertLive.Index do
  use CaseManagerWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <.table
      id="alerts"
      rows={@streams.alerts}
      row_click={fn {_id, alert} -> JS.navigate(~p"/alerts/#{alert}") end}
    >
      <:col :let={{_id, _alert}}></:col>
      <:col :let={{_id, alert}} label="Customer"><%= alert.team_id %></:col>
      <:col :let={{_id, alert}} label="Title"><%= alert.title %></:col>
      <:col :let={{_id, alert}} label="Risk Level"><%= alert.risk_level %></:col>
      <:col :let={{_id, alert}} label="Start Time"><%= alert.start_time %></:col>
      <:col :let={{_id, alert}} label="Case ID"></:col>
      <:col :let={{_id, alert}} label="Case Status"></:col>
      <:col :let={{_id, alert}} label="Link"><%= alert.link %></:col>
    </.table>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :alerts, Ash.read!(CaseManager.Alerts.Alert))}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Alerts")
    |> assign(:alert, nil)
  end
end
