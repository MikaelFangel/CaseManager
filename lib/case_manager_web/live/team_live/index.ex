defmodule CaseManagerWeb.TeamLive.Index do
  use CaseManagerWeb, :live_view
  alias CaseManager.Teams.Team

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket), do: CaseManagerWeb.Endpoint.subscribe("team:created")

    page = Team.read_by_name_asc!(load: [:email, :phone, :ip])
    teams = page.results

    socket =
      socket
      |> assign(:menu_item, :teams)
      |> stream(:teams, teams)
      |> assign(:page, page)
      |> assign(:more_pages?, page.more?)
      |> assign(:selected_team, nil)

    {:ok, socket}
  end

  @impl true
  def handle_params(_params, _url, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("load_more_teams", _params, socket) do
    page = Ash.page!(socket.assigns.page, :next)
    teams = page.results

    socket =
      socket
      |> stream(:teams, teams)
      |> assign(:page, page)
      |> assign(:more_pages?, page.more?)

    {:noreply, socket}
  end
end
