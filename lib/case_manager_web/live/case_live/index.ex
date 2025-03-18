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
    params =
      remove_empty(%{
        q: search,
        filter: socket.assigns[:filter],
        sort_by: socket.assigns[:sort_by],
        team_name: socket.assigns[:team_filter]
      })

    {:noreply, push_patch(socket, to: ~p"/?#{params}")}
  end

  @impl true
  def handle_event("change-team", %{"team_filter" => team_name}, socket) do
    params =
      remove_empty(%{
        q: socket.assigns[:search],
        filter: socket.assigns[:filter],
        sort_by: socket.assigns[:sort_by],
        team_name: team_name
      })

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

    params =
      remove_empty(%{
        q: socket.assigns[:search],
        filter: filter,
        sort_by: socket.assigns[:sort_by],
        team_name: socket.assigns[:team_filter]
      })

    {:noreply, push_patch(socket, to: ~p"/?#{params}")}
  end

  @impl true
  def handle_event("change-sort", %{"sort_by" => sort}, socket) do
    params =
      remove_empty(%{
        q: socket.assigns[:search],
        filter: socket.assigns[:filter],
        sort_by: sort,
        team_name: socket.assigns[:team_filter]
      })

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

    ~H"""
    <form data-role="cases-filter" class="hidden sm:inline" phx-change="change-filter">
      <.input
        type="select"
        id="filter_on"
        name="filter_on"
        options={@options}
        value={@selected}
        class="px-2 py-0.5 !w-fit !inline-block pr-8 text-sm"
      />
    </form>
    """
  end

  def team_changer(assigns) do
    assigns = assign(assigns, :options, team_options())

    ~H"""
    <form data-role="team-filter" class="hidden sm:inline" phx-change="change-team">
      <.input
        type="select"
        id="team_filter"
        name="team_filter"
        options={@options}
        value={@selected}
        class="px-2 py-0.5 !w-fit !inline-block pr-8 text-sm"
      />
    </form>
    """
  end

  def sort_changer(assigns) do
    assigns = assign(assigns, :options, sort_options())

    ~H"""
    <form data-role="cases-sort" class="hidden sm:inline" phx-change="change-sort">
      <.input
        type="select"
        id="sort_by"
        name="sort_by"
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

  defp remove_empty(params) do
    Enum.filter(params, fn {_key, val} -> val != "" end)
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
