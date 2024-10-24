defmodule CaseManagerWeb.CaseLive.Index do
  use CaseManagerWeb, :live_view
  require Ash.Query

  @open_statuses [:in_progress, :pending]
  @closed_statuses [:t_positive, :f_positive, :benign]

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket), do: CaseManagerWeb.Endpoint.subscribe("case:created")
    CaseManager.SelectedAlerts.drop_selected_alerts(socket.assigns.current_user.id)

    {:ok,
     socket
     |> assign(:menu_item, :cases)
     |> assign(:status_type, :open)
     |> load_cases()
     |> assign(:more_pages?, false)}
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
     stream(
       socket,
       :cases,
       next_page.results
     )
     |> assign(:current_page, next_page)
     |> assign(:more_pages?, next_page.more?)}
  end

  @impl true
  def handle_info(
        %Phoenix.Socket.Broadcast{
          event: "create",
          payload: %Ash.Notifier.Notification{data: case}
        },
        socket
      ) do
    {:noreply, stream_insert(socket, :cases, case, at: 0)}
  end

  defp reset_and_load_cases(socket) do
    socket
    |> stream(:cases, [], reset: true)
    |> load_cases()
  end

  defp load_cases(socket) do
    statuses =
      case socket.assigns.status_type do
        :open -> @open_statuses
        :closed -> @closed_statuses
      end

    current_user_team = Ash.load!(socket.assigns.current_user, :team).team

    view_rights =
      case current_user_team.type do
        :mssp ->
          Ash.Filter.parse!(CaseManager.Cases.Case, true)

        _other ->
          Ash.Filter.parse!(CaseManager.Cases.Case,
            team_id: current_user_team.id,
            escalated: true
          )
      end

    cases_page =
      CaseManager.Cases.Case
      |> Ash.Query.filter(^view_rights)
      |> Ash.Query.filter(status in ^statuses)
      |> Ash.Query.sort(updated_at: :desc)
      |> Ash.read!(action: :read_paginated)

    socket
    # Reset stream to ensure no duplicates
    |> stream(:cases, cases_page.results, reset: true)
    |> assign(:current_page, cases_page)
    |> assign(:more_pages?, cases_page.more?)
  end
end
