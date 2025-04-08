defmodule CaseManagerWeb.AlertLive.Index do
  @moduledoc false
  use CaseManagerWeb, :live_view

  alias CaseManager.Incidents

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.split flash={@flash}>
      <:top>
        <.header>
          <:actions>
            <.button :if={length(@selected_alerts) > 0} variant="primary" phx-click="process_selected">
              Process {length(@selected_alerts)} Selected
            </.button>
            <.button variant="primary" navigate={~p"/alert/new"}>
              <.icon name="hero-plus" /> New Alert
            </.button>
          </:actions>
        </.header>
      </:top>
      <:left>
        <.table id="alert" rows={@streams.alert_collection} row_click={fn {_id, alert} -> JS.push("show_alert", value: %{id: alert.id}) end} selectable={true} selected={@selected_alerts} on_toggle_selection={JS.push("toggle_selection")}>
          <:col :let={{_id, alert}} label="Company">{alert.company.name}</:col>
          <:col :let={{_id, alert}} label="Title">{alert.title}</:col>
          <:col :let={{_id, alert}} label="Risk Level">{alert.risk_level |> to_string() |> String.capitalize()}</:col>
          <:col :let={{_id, alert}}>
            <.status type={
              case alert.status do
                :new -> "info"
                :reviewed -> "warning"
                :false_positive -> nil
                :linked_to_case -> nil
                _ -> "error"
              end
            } />
          </:col>
        </.table>
      </:left>

      <:right>
        <%= if @selected_alert do %>
          <.header>
            {@selected_alert.title}
            <:subtitle>{@selected_alert.company_id}</:subtitle>
            <:actions>
              <.button navigate={~p"/alert/#{@selected_alert}/edit"}>Edit</.button>
            </:actions>
          </.header>

          <div class="mt-8">
            <h3 class="font-medium text-lg mb-2">Risk Level</h3>
            <div class="mb-6">
              <.badge type={
                case @selected_alert.risk_level do
                  :critical -> :error
                  :high -> :warning
                  :medium -> :neutral
                  :low -> :success
                  :info -> :info
                end
              }>
                {@selected_alert.risk_level |> to_string() |> String.capitalize()}
              </.badge>
            </div>

            <h3 class="font-medium text-lg mb-2">Description</h3>
            <div class="prose">
              <p>{@selected_alert.description || "No description provided."}</p>
            </div>
          </div>
        <% else %>
          <div class="flex h-full items-center justify-center text-base-content/70">
            <p>Select an alert to view details</p>
          </div>
        <% end %>
      </:right>
    </Layouts.split>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Listing Alert")
     |> assign(:selected_alerts, [])
     |> assign(:selected_alert, nil)
     |> stream(:alert_collection, Incidents.list_alert!())}
  end

  @impl true
  def handle_params(%{"id" => id}, _uri, socket) do
    alert = Incidents.get_alert!(id)
    {:noreply, assign(socket, :selected_alert, alert)}
  end

  @impl true
  def handle_params(_params, _uri, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    alert = Incidents.get_alert!(id)
    {:ok, _} = Incidents.delete_alert(alert)

    {:noreply, stream_delete(socket, :alert_collection, alert)}
  end

  @impl true
  def handle_event("toggle_selection", %{"id" => id}, socket) do
    selected_alerts = socket.assigns.selected_alerts

    updated_selected =
      if id in selected_alerts do
        List.delete(selected_alerts, id)
      else
        [id | selected_alerts]
      end

    {:noreply, assign(socket, :selected_alerts, updated_selected)}
  end

  @impl true
  def handle_event("process_selected", _params, socket) do
    selected_alerts = socket.assigns.selected_alerts

    socket = put_flash(socket, :info, "Processing #{length(selected_alerts)} alerts")

    {:noreply, socket}
  end

  @impl true
  def handle_event("show_alert", %{"id" => id}, socket) do
    alert = Incidents.get_alert!(id)
    {:noreply, assign(socket, :selected_alert, alert)}
  end
end
