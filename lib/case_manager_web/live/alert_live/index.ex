defmodule CaseManagerWeb.AlertLive.Index do
  @moduledoc false
  use CaseManagerWeb, :live_view

  alias CaseManager.ICM
  alias CaseManager.SelectedAlerts
  alias CaseManagerWeb.Helpers

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket), do: CaseManagerWeb.Endpoint.subscribe("alert:created")
    current_user = socket.assigns[:current_user]
    SelectedAlerts.drop_selected_alerts(current_user.id)
    alerts = ICM.list_alerts!(actor: current_user)

    {:ok,
     socket
     |> stream(:alerts, alerts.results)
     |> assign(:logo_img, Helpers.load_logo())
     |> assign(:selected_alerts, [])
     |> assign(:current_page, alerts)
     |> assign(:menu_item, :alerts)
     |> assign(:more_alerts?, alerts.more?)}
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

  @impl true
  def handle_info(%Phoenix.Socket.Broadcast{event: "create", payload: %Ash.Notifier.Notification{data: alert}}, socket) do
    alert = Ash.load!(alert, [:team, :case])
    {:noreply, stream_insert(socket, :alerts, alert, at: 0)}
  end

  @impl true
  def handle_event("show_modal", %{"alert_id" => alert_id}, socket) do
    alert = ICM.get_alert_by_id!(alert_id, load: :team, actor: socket.assigns[:current_user])
    socket = assign(socket, :alert, alert)

    {:noreply, socket}
  end

  @impl true
  def handle_event("hide_modal", _params, socket) do
    socket = assign(socket, :alert, nil)

    {:noreply, socket}
  end

  def handle_event(
        "toggle_alert_selection",
        %{"alert_id" => alert_id, "team_id" => team_id, "checkbox_id" => checkbox_id},
        socket
      ) do
    user_id = socket.assigns.current_user.id

    socket =
      case SelectedAlerts.toggle_alert_selection(user_id, alert_id, team_id) do
        :ok ->
          socket

        {:error, _error} ->
          socket
          |> push_event("deselect-checkbox", %{checkbox_id: checkbox_id})
          |> put_flash(
            :error,
            gettext("The selected alerts must be associated with the same team!")
          )
      end

    selected_alerts = SelectedAlerts.get_selected_alerts(user_id)
    {:noreply, assign(socket, :selected_alerts, selected_alerts)}
  end

  @impl true
  def handle_event("load_more_alerts", _params, socket) do
    current_page = socket.assigns.current_page
    next_page = Ash.page!(current_page, :next)

    alerts = next_page.results

    {:noreply,
     socket
     |> stream(:alerts, alerts)
     |> assign(:current_page, next_page)
     |> assign(:more_alerts?, next_page.more?)}
  end
end
