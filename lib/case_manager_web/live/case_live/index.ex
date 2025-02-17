defmodule CaseManagerWeb.CaseLive.Index do
  @moduledoc false
  use CaseManagerWeb, :live_view

  alias Ash.Notifier.Notification
  alias CaseManager.ICM
  alias CaseManagerWeb.Endpoint
  alias CaseManagerWeb.Helpers
  alias Phoenix.Socket.Broadcast

  require Ash.Query

  @open_statuses [:in_progress, :pending]
  @closed_statuses [:t_positive, :f_positive, :benign]

  @impl true
  def mount(_params, _session, socket) do
    current_user = socket.assigns.current_user

    if connected?(socket) do
      if current_user.team_type == :mssp do
        Endpoint.subscribe("case:created")
        Endpoint.subscribe("case:escalated:all")
        Endpoint.subscribe("case:updated:all")
      else
        Endpoint.subscribe("case:escalated:" <> current_user.team_id)
        Endpoint.subscribe("case:updated:" <> current_user.team_id)
      end
    end

    CaseManager.SelectedAlerts.drop_selected_alerts(current_user.id)

    {:ok,
     socket
     |> assign(:menu_item, :cases)
     |> assign(:status_type, :open)
     |> assign(:logo_img, Helpers.load_logo())
     |> load_cases()}
  end

  @impl true
  def handle_event("open_cases", _params, socket) do
    {:noreply,
     socket
     |> assign(:status_type, :open)
     |> reset_and_load_cases()}
  end

  @impl true
  def handle_event("closed_cases", _params, socket) do
    {:noreply,
     socket
     |> assign(:status_type, :closed)
     |> reset_and_load_cases()}
  end

  @impl true
  def handle_event("load_more_cases", _params, socket) do
    next_page = Ash.page!(socket.assigns.current_page, :next)

    {:noreply,
     socket
     |> stream(:cases, next_page.results)
     |> assign(:current_page, next_page)
     |> assign(:more_cases?, next_page.more?)}
  end

  @impl true
  def handle_info(%Broadcast{event: event, payload: %Notification{data: case}}, socket)
      when event in ["create", "escalate"] do
    case = Ash.load!(case, [:team, :assignee, :updated_since_last?], actor: socket.assigns.current_user)
    {:noreply, stream_insert(socket, :cases, case, at: 0)}
  end

  @impl true
  def handle_info(
        %Broadcast{topic: "case:updated" <> _channel, event: event, payload: %Notification{data: case}},
        socket
      ) do
    socket =
      if event == "view" do
        socket
      else
        case = Ash.load!(case, [:team, :assignee, :updated_since_last?], actor: socket.assigns.current_user)
        stream_insert(socket, :cases, case)
      end

    {:noreply, socket}
  end

  defp reset_and_load_cases(socket) do
    socket
    |> stream(:cases, [], reset: true)
    |> load_cases()
  end

  defp load_cases(socket) do
    assigns = socket.assigns

    statuses =
      case assigns.status_type do
        :open -> @open_statuses
        :closed -> @closed_statuses
      end

    cases =
      ICM.list_cases!(
        query: [filter: [status: [in: statuses]], sort_input: "-updated_at", load: [:last_viewed, :updated_since_last?]],
        actor: assigns.current_user
      )

    socket
    # Reset stream to ensure no duplicates
    |> stream(:cases, cases.results, reset: true)
    |> assign(:current_page, cases)
    |> assign(:more_cases?, cases.more?)
  end
end
