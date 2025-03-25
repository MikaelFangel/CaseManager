defmodule CaseManagerWeb.CaseLive.Index do
  @moduledoc false
  use CaseManagerWeb, :live_view

  alias Ash.Notifier.Notification
  alias CaseManager.ICM
  alias CaseManagerWeb.Endpoint
  alias CaseManagerWeb.Helpers
  alias Phoenix.Socket.Broadcast

  @impl true
  def mount(_params, _session, socket) do
    current_user = socket.assigns.current_user
    if connected?(socket), do: subscribe_to_topics(current_user)

    CaseManager.SelectedAlerts.drop_selected_alerts(current_user.id)

    socket =
      socket
      |> assign(:menu_item, :cases)
      |> assign(:filter_on, :open)
      |> assign(:logo_img, Helpers.load_logo())

    {:ok, socket}
  end

  @impl true
  def handle_params(params, _uri, socket) do
    query_text = Map.get(params, "q", "")
    sort_by = Map.get(params, "sort_by", "-updated_at")
    filter = Map.get(params, "filter", %{is_closed: false})

    cases =
      ICM.search_cases!(
        query_text,
        query: [filter_input: filter, sort_input: sort_by, load: [:last_viewed, :updated_since_last?, :is_closed]],
        actor: socket.assigns[:current_user]
      )

    socket =
      socket
      |> stream(:cases, cases.results, reset: true)
      |> assign(:current_page, cases)
      |> assign(:more_cases?, cases.more?)
      |> assign(:sort_by, sort_by)
      |> assign(:filter, filter)
      |> assign(:search, query_text)

    {:noreply, socket}
  end

  @impl true
  def handle_event("search", %{"search" => search}, socket) do
    params = Helpers.update_params(socket, %{q: search})
    {:noreply, push_patch(socket, to: ~p"/?#{params}")}
  end

  @impl true
  def handle_event(
        "change-filtering",
        %{"team-filter" => team, "cases-filter" => case_status, "cases-sort" => sort},
        socket
      ) do
    filter =
      %{}
      |> maybe_add_team(team)
      |> maybe_add_case(case_status)

    params = Helpers.update_params(socket, %{filter: filter, sort_by: sort})
    {:noreply, push_patch(socket, to: ~p"/?#{params}")}
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

  def filter_changer(assigns) do
    ~H"""
    <.filter_input id="cases-filter" options={filter_options()} selected={@selected} />
    """
  end

  def sort_changer(assigns) do
    ~H"""
    <.filter_input id="cases-sort" options={sort_options()} selected={@selected} />
    """
  end

  defp maybe_add_team(filter, ""), do: filter
  defp maybe_add_team(filter, team), do: Map.put(filter, :team, %{name: team})

  defp maybe_add_case(filter, "open"), do: Map.put(filter, :is_closed, false)
  defp maybe_add_case(filter, "closed"), do: Map.put(filter, :is_closed, true)
  defp maybe_add_case(filter, _), do: filter

  defp filter_options do
    [
      {"Open Cases", :open},
      {"Closed Cases", :closed}
    ]
  end

  defp sort_options do
    [
      {"Time since updated", "-updated_at"},
      {"Priority", "priority"},
      {"Title", "title"},
      {"Team", "team.name"},
      {"Escalated", "-escalated"}
    ]
  end

  defp subscribe_to_topics(user) do
    if user.team_type == :mssp do
      Endpoint.subscribe("case:created")
      Endpoint.subscribe("case:escalated:all")
      Endpoint.subscribe("case:updated:all")
    else
      Endpoint.subscribe("case:escalated:" <> user.team_id)
      Endpoint.subscribe("case:updated:" <> user.team_id)
    end
  end
end
