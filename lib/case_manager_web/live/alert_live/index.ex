defmodule CaseManagerWeb.AlertLive.Index do
  @moduledoc false
  use CaseManagerWeb, :live_view

  alias CaseManager.ICM
  alias CaseManager.SelectedAlerts
  alias CaseManagerWeb.Helpers

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket), do: CaseManagerWeb.Endpoint.subscribe("alert:created")
    current_user = socket.assigns[:current_user]
    SelectedAlerts.drop_selected_alerts(current_user.id)

    {:ok,
     socket
     |> assign(:logo_img, Helpers.load_logo())
     |> assign(:selected_alerts, [])
     |> assign(:menu_item, :alerts)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    query_text = Map.get(params, "q", "")
    team_name = Map.get(params, "team_name", "")
    team_filter = if team_name == "", do: %{}, else: %{team: %{name: team_name}}

    alerts =
      ICM.search_alerts!(query_text,
        query: [filter_input: team_filter, load: :team],
        actor: socket.assigns[:current_user]
      )

    socket =
      socket
      |> stream(:alerts, alerts.results, reset: true)
      |> assign(:current_page, alerts)
      |> assign(:more_alerts?, alerts.more?)
      |> assign(:search, query_text)
      |> assign(:team_filter, team_name)

    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Alerts")
    |> assign(:alert, nil)
  end

  @impl true
  def handle_info(%Phoenix.Socket.Broadcast{event: "create", payload: %Ash.Notifier.Notification{data: alert}}, socket) do
    alert = Ash.load!(alert, [:team, :case])
    {:noreply, stream_insert(socket, :alerts, alert, at: 0)}
  end

  @impl true
  def handle_event("search", %{"search" => search}, socket) do
    params = remove_empty(%{q: search})
    {:noreply, push_patch(socket, to: ~p"/alerts/?#{params}")}
  end

  @impl true
  def handle_event("change-team", %{"team_filter" => team_name}, socket) do
    params = update_params(socket, %{team_name: team_name})
    {:noreply, push_patch(socket, to: ~p"/alerts/?#{params}")}
  end

  defp update_params(socket, updates) do
    remove_empty(%{
      q: Map.get(updates, :q, socket.assigns[:search]),
      filter: Map.get(updates, :filter, socket.assigns[:filter]),
      sort_by: Map.get(updates, :sort_by, socket.assigns[:sort_by]),
      team_name: Map.get(updates, :team_name, socket.assigns[:team_filter])
    })
  end

  @impl true
  def handle_event("show", %{"alert_id" => alert_id}, socket) do
    alert = ICM.get_alert_by_id!(alert_id, load: [:team, :enrichments], actor: socket.assigns[:current_user])
    socket = assign(socket, :alert, alert)

    {:noreply, socket}
  end

  def handle_event(
        "toggle_alert_selection",
        %{"alert_id" => alert_id, "team_id" => team_id, "checkbox_id" => checkbox_id},
        socket
      ) do
    user_id = socket.assigns.current_user.id

    socket =
      case SelectedAlerts.toggle_alert_selection(user_id, alert_id, team_id) do
        :ok ->
          socket

        {:error, _error} ->
          socket
          |> push_event("deselect-checkbox", %{checkbox_id: checkbox_id})
          |> put_flash(
            :error,
            gettext("The selected alerts must be associated with the same team!")
          )
      end

    selected_alerts = SelectedAlerts.get_selected_alerts(user_id)
    {:noreply, assign(socket, :selected_alerts, selected_alerts)}
  end

  @impl true
  def handle_event("load_more_alerts", _params, socket) do
    current_page = socket.assigns.current_page
    next_page = Ash.page!(current_page, :next)

    alerts = next_page.results

    {:noreply,
     socket
     |> stream(:alerts, alerts)
     |> assign(:current_page, next_page)
     |> assign(:more_alerts?, next_page.more?)}
  end

  defp remove_empty(params) do
    Enum.filter(params, fn {_key, val} -> val != "" end)
  end

  defp team_options(current_user) do
    [
      {"All teams", ""}
      | [actor: current_user] |> CaseManager.Teams.list_teams!() |> Enum.map(&{&1.name, &1.name}) |> Enum.uniq()
    ]
  end

  def team_changer(assigns) do
    assigns = assign(assigns, :options, team_options(assigns.current_user))
    render_changer(assigns, "team-filter", "change-team", "team_filter")
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
end
