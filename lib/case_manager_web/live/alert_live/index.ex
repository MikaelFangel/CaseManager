defmodule CaseManagerWeb.AlertLive.Index do
  use CaseManagerWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket), do: CaseManagerWeb.Endpoint.subscribe("alert:created")
    CaseManager.SelectedAlerts.drop_selected_alerts(socket.assigns.current_user.id)

    alerts_page =
      CaseManager.Alerts.Alert
      |> Ash.Query.sort(inserted_at: :desc)
      |> Ash.read!(action: :read_paginated)

    alerts = alerts_page.results

    {:ok,
     stream(
       socket,
       :alerts,
       alerts
     )
     |> assign(:show_modal, false)
     |> assign(:alert, %{})
     |> assign(:selected_alerts, [])
     |> assign(:current_page, alerts_page)
     |> assign(:menu_item, :alerts)
     |> assign(:more_pages?, alerts_page.more?)}
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
    {:noreply, stream_insert(socket, :alerts, alert, at: 0)}
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

  def handle_event(
        "toggle_alert_selection",
        %{"alert_id" => alert_id, "team_id" => team_id, "checkbox_id" => checkbox_id},
        socket
      ) do
    user_id = socket.assigns.current_user.id

    socket =
      case CaseManager.SelectedAlerts.toggle_alert_selection(user_id, alert_id, team_id) do
        :ok ->
          socket

        {:error, _} ->
          socket
          |> push_event("deselect-checkbox", %{checkbox_id: checkbox_id})
          |> put_flash(
            :error,
            gettext("The selected alerts must be associated with the same team!")
          )
      end

    selected_alerts = CaseManager.SelectedAlerts.get_selected_alerts(user_id)
    {:noreply, assign(socket, :selected_alerts, selected_alerts)}
  end

  @impl true
  def handle_event("load_more_alerts", _params, socket) do
    current_page = socket.assigns.current_page
    next_page = Ash.page!(current_page, :next)

    alerts = next_page.results

    {:noreply,
     stream(
       socket,
       :alerts,
       alerts
     )
     |> assign(:current_page, next_page)
     |> assign(:more_pages?, next_page.more?)}
  end
end
