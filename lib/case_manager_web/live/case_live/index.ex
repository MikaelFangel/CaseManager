defmodule CaseManagerWeb.CaseLive.Index do
  @moduledoc false
  use CaseManagerWeb, :live_view

  alias CaseManager.ICM.Case
  alias CaseManagerWeb.Helpers

  require Ash.Query

  @open_statuses [:in_progress, :pending]
  @closed_statuses [:t_positive, :f_positive, :benign]

  @impl true
  def mount(_params, _session, socket) do
    current_user = socket.assigns.current_user
    if connected?(socket) do
      if current_user.team_type == :mssp, do: CaseManagerWeb.Endpoint.subscribe("case:created")
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
     |> assign(:more_pages?, next_page.more?)}
  end

  @impl true
  def handle_info(%Phoenix.Socket.Broadcast{event: "create", payload: %Ash.Notifier.Notification{data: case}}, socket) do
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

    cases_page =
      Case
      |> Ash.Query.filter(status in ^statuses)
      |> Ash.Query.sort(updated_at: :desc)
      |> Ash.Query.load(assignee: [:full_name])
      |> Ash.read!(action: :read_paginated, actor: socket.assigns.current_user)

    socket
    # Reset stream to ensure no duplicates
    |> stream(:cases, cases_page.results, reset: true)
    |> assign(:current_page, cases_page)
    |> assign(:more_pages?, cases_page.more?)
  end
end
