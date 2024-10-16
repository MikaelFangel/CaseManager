defmodule CaseManagerWeb.AlertLive.Index do
  use CaseManagerWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <div class="p-0 pl-6 pr-8">
      <div class="flex justify-end my-4 gap-x-2">
        <.icon_btn icon_name="hero-pause-circle" colour={:critical} />
        <.link navigate={~p"/case/new"}>
          <.button
            icon_name="hero-document-plus"
            phx-click="create_case"
            disabled={Enum.empty?(@selected_alerts)}
          >
            <%= gettext("Create Case") %>
          </.button>
        </.link>
      </div>

      <div
        class="mt-12"
        id="alerts-container"
        phx-update="stream"
        phx-viewport-bottom={@more_pages? && "load_more_alerts"}
      >
        <.table
          id="alerts"
          rows={@streams.alerts}
          row_click={
            fn {_id, alert} ->
              JS.push("show_modal", value: alert) |> show_modal("alert_modal")
            end
          }
        >
          <:col :let={{_id, alert}} not_clickable_area?>
            <.input
              type="checkbox"
              name="checkbox_name"
              phx-click="toggle_alert_selection"
              phx-value-id={alert.id}
            />
          </:col>
          <:col :let={{_id, alert}} label={gettext("Team")} width="36"><%= alert.team.name %></:col>
          <:col :let={{_id, alert}} label={gettext("Title")}><%= alert.title %></:col>
          <:col :let={{_id, alert}} label={gettext("Risk Level")} width="16">
            <.risk_badge colour={alert.risk_level} />
          </:col>
          <:col :let={{_id, alert}} label={gettext("Creation Time")}><%= alert.creation_time %></:col>
          <:col :let={{_id, _alert}} label={gettext("Case ID")} width="36" not_clickable_area?>
            <.tooltip pos={:top} tooltip_label="Pending">
              <.txt_link label="3h6g3f6v" />
            </.tooltip>
          </:col>
          <:col :let={{_id, alert}} label={gettext("Link")} width="8" not_clickable_area?>
            <.icon_btn
              icon_name="hero-arrow-top-right-on-square"
              colour={:secondary}
              size={:small}
              class="pl-0.5 pb-1"
              phx-click={alert.link}
            />
            <!-- <.link navigate={alert.link} target="_blank"><%= alert.link %></.link> -->
          </:col>
        </.table>
      </div>

      <%= if @more_pages? do %>
        <div class="flex justify-center my-4">
          <.button phx-click="load_more_alerts"><%= gettext("Load More") %></.button>
        </div>
      <% else %>
        <div class="flex justify-center my-4">
          <span class="text-black text-xs font-semibold"><%= gettext("No more alerts") %></span>
        </div>
      <% end %>
    </div>

    <.modal :if={@show_modal} id="alert_modal" show on_cancel={JS.push("hide_modal")}>
      <div class="modal-content">
        <.header><%= @alert.title %></.header>
        <hr class="border-t border-gray-300 my-4" /> Creation Time: <%= @alert.creation_time %> <br />
        Case ID: <br /> Case Status: <br /> Risk Level: <%= @alert.risk_level %> <br />
        Team: <%= @alert.team_id %> <br /> Alert ID: <%= @alert.id %>
        <%= @alert.description %>
        <br />
        <br />
        <pre><%= 
          if @alert.additional_data != %{} do
            @alert.additional_data
            |> Jason.encode!(pretty: true)
          end
          %> </pre>
        <br />
        <div class="flex justify-end space-x-2">
          <.button colour={:secondary} phx-click="hide_modal">Close</.button>
          <.button colour={:secondary} phx-click="hide_modal">Search Link</.button>
          <.button phx-click="hide_modal">Create Case</.button>
        </div>
      </div>
    </.modal>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket), do: CaseManagerWeb.Endpoint.subscribe("alert:created")
    CaseManager.SelectedAlerts.drop_selected_alerts(socket.assigns.current_user.id)

    alerts_page =
      CaseManager.Alerts.Alert
      |> Ash.Query.sort(inserted_at: :desc)
      |> Ash.read!()

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

  def handle_event("toggle_alert_selection", %{"id" => id}, socket) do
    user_id = socket.assigns.current_user.id
    CaseManager.SelectedAlerts.toggle_alert_selection(user_id, id)

    selected_alerts = CaseManager.SelectedAlerts.get_selected_alerts(user_id)
    {:noreply, assign(socket, :selected_alerts, selected_alerts)}
  end

  def handle_event("create_case", _params, socket) do
    {:noreply, socket}
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
