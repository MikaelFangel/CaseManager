defmodule CaseManagerWeb.CaseLive.Index do
  @moduledoc false
  use CaseManagerWeb, :live_view

  alias CaseManager.Incidents

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} search_placeholder="Search cases" user_roles={@user_roles}>
      <.header>
        <div>
          <.status_filter selected={@filter_option} />
        </div>

        <:actions>
          <.button variant="primary" navigate={~p"/case/new"} hidden>
            <.icon name="hero-plus" /> New Case
          </.button>
        </:actions>
      </.header>

      <.table id="cases" rows={@streams.cases} row_click={fn {_id, case} -> JS.navigate(~p"/case/#{case}") end}>
        <:col :let={{_id, case}} label="Company">{case.company.name}</:col>
        <:col :let={{_id, case}} label="Title">{case.title}</:col>
        <:col :let={{_id, case}} label="Status">
          <.badge type={status_to_badge_type(case.status)} modifier={:outline}>
            {case.status |> to_string() |> String.split("_") |> Enum.join(" ") |> String.capitalize()}
          </.badge>
        </:col>

        <:col :let={{_id, case}} label="Assignee">{case.assignee}</:col>
      </.table>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    user = Ash.load!(socket.assigns.current_user, [:companies, :socs, :soc_roles, :company_roles, :super_admin?])

    if connected?(socket) do
      if user.super_admin? do
        CaseManagerWeb.Endpoint.subscribe("case")
      end

      Enum.each(user.companies, fn company -> CaseManagerWeb.Endpoint.subscribe("case:#{company.id}") end)
      Enum.each(user.socs, fn soc -> CaseManagerWeb.Endpoint.subscribe("case:#{soc.id}") end)
    end

    {:ok,
     socket
     |> assign(:page_title, "Listing Cases")
     |> assign(:user_roles, user.soc_roles ++ user.company_roles)}
  end

  @impl true
  def handle_params(params, _uri, socket) do
    user = Ash.load!(socket.assigns.current_user, :super_admin?)
    query = Map.get(params, "q", "")

    filter_option = Map.get(params, "filter", "all")
    filter = get_filter_for_option(filter_option)

    cases = Incidents.search_cases!(query, query: [filter_input: filter, load: [:company]], actor: user)

    socket =
      socket
      |> stream(:cases, cases, reset: true)
      |> assign(query: query)
      |> assign(filter_option: filter_option)
      |> assign(filter: filter)

    {:noreply, socket}
  end

  @impl true
  def handle_event("search", %{"query" => search}, socket) do
    params = update_params(socket, %{q: search})
    {:noreply, push_patch(socket, to: ~p"/case/?#{params}")}
  end

  @impl true
  def handle_event("filter", %{"status-filter" => filter}, socket) do
    params = update_params(socket, %{filter: filter})
    {:noreply, push_patch(socket, to: ~p"/case/?#{params}")}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    case = Incidents.get_case!(id, actor: socket.assigns.current_user)
    {:ok, _} = Incidents.delete_case(case, actor: socket.assigns.current_user)

    {:noreply, stream_delete(socket, :cases, case)}
  end

  @impl true
  def handle_info(%{topic: "case:" <> _company, event: "create", payload: notification}, socket) do
    case = Ash.load!(notification.data, [:company])
    socket = stream_insert(socket, :cases, case, at: 0)

    {:noreply, socket}
  end

  defp status_to_badge_type(status) do
    case status do
      :new -> :info
      :open -> :info
      :in_progress -> :warning
      :pending -> :warning
      :resolved -> :success
      :closed -> :neutral
      :reopened -> :error
      _ -> :neutral
    end
  end

  def status_filter(assigns) do
    ~H"""
    <.form for={%{}} phx-change="filter">
      <.input type="select" id="status-filter" name="status-filter" options={filter_options()} value={@selected} />
    </.form>
    """
  end

  defp filter_options do
    [
      {"All Cases", "all"},
      {"Open Cases", "open"},
      {"In Progress Cases", "in_progress"},
      {"Pending Cases", "pending"},
      {"Resolved Cases", "resolved"},
      {"Closed Cases", "closed"},
      {"Reopened Cases", "reopened"}
    ]
  end

  defp update_params(socket, updates) do
    remove_empty(%{
      q: Map.get(updates, :q, socket.assigns[:search]),
      filter: Map.get(updates, :filter, socket.assigns[:filter]),
      sort_by: Map.get(updates, :sort_by, socket.assigns[:sort_by])
    })
  end

  defp remove_empty(params) do
    Enum.filter(params, fn {_key, val} -> val != "" and val != nil end)
  end

  defp get_filter_for_option("all"), do: %{}
  defp get_filter_for_option("open"), do: %{status: [in: [:new, :open, :reopened]]}
  defp get_filter_for_option("in_progress"), do: %{status: [in: [:in_progress]]}
  defp get_filter_for_option("pending"), do: %{status: [in: [:pending]]}
  defp get_filter_for_option("resolved"), do: %{status: [in: [:resolved]]}
  defp get_filter_for_option("closed"), do: %{status: [in: [:closed]]}
  defp get_filter_for_option("reopened"), do: %{status: [in: [:reopened]]}
  defp get_filter_for_option(_), do: %{status: [in: [:closed, :resolved]]}
end
