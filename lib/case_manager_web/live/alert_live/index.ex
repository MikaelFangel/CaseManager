defmodule CaseManagerWeb.AlertLive.Index do
  use CaseManagerWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <.table
      id="alerts"
      rows={@streams.alerts}
      row_click={fn {_id, alert} -> JS.push("show_modal", value: alert) end}
    >
      <:col :let={{_id, _alert}}></:col>
      <:col :let={{_id, alert}} label={gettext("Team")}><%= alert.team.name %></:col>
      <:col :let={{_id, alert}} label={gettext("Title")}><%= alert.title %></:col>
      <:col :let={{_id, alert}} label={gettext("Risk Level")}><%= alert.risk_level %></:col>
      <:col :let={{_id, alert}} label={gettext("Start Time")}><%= alert.start_time %></:col>
      <:col :let={{_id, _alert}} label={gettext("Case ID")}></:col>
      <:col :let={{_id, _alert}} label={gettext("Case Status")}></:col>
      <:col :let={{_id, alert}} label={gettext("Link")}>
        <.link navigate={alert.link} target="_blank"><%= alert.link %></.link>
      </:col>
    </.table>

    <.modal :if={@show_modal} id="alert_modal" show on_cancel={JS.push("hide_modal")}>
      <div class="modal-content">
        <.header><%= @alert.title %></.header>
        <hr class="border-t border-gray-300 my-4" />
        Time Range: <%= @alert.start_time %> - <%= @alert.end_time %>
        Case ID: Case Status:
        Risk Level: <%= @alert.risk_level %> <br />
        Team: <%= @alert.team_id %> Alert ID: <%= @alert.id %>
        <%= @alert.description %>
        <br/>
        <br/>
        <pre><%= 
          if @alert.additional_data != %{} do
            @alert.additional_data
            |> Jason.encode!(pretty: true)
          end
          %> </pre>
        <br/>
        <div class="flex justify-end space-x-2">
          <.button phx-click="hide_modal">Close</.button>
          <.button phx-click="hide_modal">Search Link</.button>
          <.button phx-click="hide_modal">Create Case</.button>
        </div>
      </div>
    </.modal>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket), do: CaseManagerWeb.Endpoint.subscribe("alert:created")

    {:ok,
     stream(socket, :alerts, Ash.read!(CaseManager.Alerts.Alert))
     |> assign(:show_modal, false)
     |> assign(:alert, %{})}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Alerts")
    |> assign(:alert, %{})
  end

  @impl true
  def handle_info(
        %Phoenix.Socket.Broadcast{
          event: "create",
          payload: %Ash.Notifier.Notification{data: alert}
        },
        socket
      ) do
    {:noreply, stream_insert(socket, :alerts, alert)}
  end

  @impl true
  def handle_event("show_modal", alert, socket) do
    alert = Map.new(alert, fn {k, v} -> {String.to_atom(k), v} end)

    {:noreply,
     assign(socket, :show_modal, true)
     |> assign(:alert, alert)}
  end

  @impl true
  def handle_event("hide_modal", _params, socket) do
    {:noreply, assign(socket, :show_modal, false)}
  end
end
