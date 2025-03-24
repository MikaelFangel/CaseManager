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
    team_name = Map.get(params, "team_name", "")
    team_filter = if team_name == "", do: %{}, else: %{team: %{name: team_name}}
    filter = Map.merge(filter, team_filter)

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
      |> assign(:team_filter, team_name)

    {:noreply, socket}
  end

  @impl true
  def handle_event("search", %{"search" => search}, socket) do
    params = update_params(socket, %{q: search})
    {:noreply, push_patch(socket, to: ~p"/?#{params}")}
  end

  @impl true
  def handle_event("change-team", %{"team_filter" => team_name}, socket) do
    params = update_params(socket, %{team_name: team_name})
    {:noreply, push_patch(socket, to: ~p"/?#{params}")}
  end

  @impl true
  def handle_event("change-filter", %{"filter_on" => filter_key}, socket) do
    filter =
      case filter_key do
        "open" -> %{is_closed: false}
        "closed" -> %{is_closed: true}
        _invalid -> %{}
      end

    params = update_params(socket, %{filter: filter})
    {:noreply, push_patch(socket, to: ~p"/?#{params}")}
  end

  @impl true
  def handle_event("change-sort", %{"sort_by" => sort}, socket) do
    params = update_params(socket, %{sort_by: sort})
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
    assigns = assign(assigns, :options, filter_options())
    render_changer(assigns, "cases-filter", "change-filter", "filter_on")
  end

  def team_changer(assigns) do
    assigns = assign(assigns, :options, team_options())
    render_changer(assigns, "team-filter", "change-team", "team_filter")
  end

  def sort_changer(assigns) do
    assigns = assign(assigns, :options, sort_options())
    render_changer(assigns, "cases-sort", "change-sort", "sort_by")
  end

  defp render_changer(assigns, data_role, event, input_id) do
    assigns = assign(assigns, data_role: data_role, event: event, input_id: input_id)

    ~H"""
    <form data-role={@data_role} class="hidden sm:inline" phx-change={@event}>
      <.input
        type="select"
        id={@input_id}
        name={@input_id}
        options={@options}
        value={@selected}
        class="px-2 py-0.5 !w-fit !inline-block pr-8 text-sm"
      />
    </form>
    """
  end

  defp team_options do
    [{"All teams", ""} | Enum.map(CaseManager.Teams.list_teams!(), &{&1.name, &1.name})]
  end

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

  defp update_params(socket, updates) do
    remove_empty(%{
      q: Map.get(updates, :q, socket.assigns[:search]),
      filter: Map.get(updates, :filter, socket.assigns[:filter]),
      sort_by: Map.get(updates, :sort_by, socket.assigns[:sort_by]),
      team_name: Map.get(updates, :team_name, socket.assigns[:team_filter])
    })
  end

  defp remove_empty(params) do
    Enum.filter(params, fn {_key, val} -> val != "" end)
  end
end
