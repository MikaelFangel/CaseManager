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
        <:col :let={{_id, case}} label="Last modified">
          {time_ago(case.updated_at)}
        </:col>

        <:col :let={{_id, case}} label="Assignee">{case.assignee && case.assignee.full_name}</:col>
      </.table>

      <%= if @page_results do %>
        <.pagination page_results={@page_results} current_page={@current_page} limit={@limit} offset={@offset} />
      <% end %>
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
     |> assign(:user_roles, user.soc_roles ++ user.company_roles)
     |> assign(:current_page, 1)
     |> assign(:limit, 10)
     |> assign(:offset, 0)
     |> assign(:page_results, nil)}
  end

  @impl true
  def handle_params(params, _uri, socket) do
    user = Ash.load!(socket.assigns.current_user, :super_admin?)
    query = Map.get(params, "q", "")

    filter_option = Map.get(params, "filter", "all")
    filter = get_filter_for_option(filter_option)

    limit = String.to_integer(params["limit"] || "10")
    offset = String.to_integer(params["offset"] || "0")

    page_results =
      Incidents.search_cases!(
        query,
        query: [filter_input: filter, sort_input: "-updated_at", load: [:company, assignee: [:full_name]]],
        page: [limit: limit, offset: offset, count: true],
        actor: user
      )

    current_page = div(offset, limit) + 1

    socket =
      socket
      |> stream(:cases, page_results.results, reset: true)
      |> assign(query: query)
      |> assign(filter_option: filter_option)
      |> assign(filter: filter)
      |> assign(:page_results, page_results)
      |> assign(:current_page, current_page)
      |> assign(:limit, limit)
      |> assign(:offset, offset)

    {:noreply, socket}
  end

  @impl true
  def handle_event("search", %{"query" => search}, socket) do
    params = %{q: search, limit: socket.assigns.limit, offset: 0}
    {:noreply, push_patch(socket, to: ~p"/case/?#{params}")}
  end

  @impl true
  def handle_event("filter", %{"status-filter" => filter}, socket) do
    params = %{filter: filter, limit: socket.assigns.limit, offset: 0}
    {:noreply, push_patch(socket, to: ~p"/case/?#{params}")}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    case = Incidents.get_case!(id, actor: socket.assigns.current_user)
    {:ok, _case} = Incidents.delete_case(case, actor: socket.assigns.current_user)

    {:noreply, stream_delete(socket, :cases, case)}
  end

  @impl true
  def handle_event("prev-page", _params, socket) do
    new_offset = max(0, socket.assigns.offset - socket.assigns.limit)

    params = %{
      q: socket.assigns.query,
      filter: socket.assigns.filter_option,
      limit: socket.assigns.limit,
      offset: new_offset
    }

    {:noreply, push_patch(socket, to: ~p"/case/?#{params}")}
  end

  @impl true
  def handle_event("next-page", _params, socket) do
    new_offset = socket.assigns.offset + socket.assigns.limit

    params = %{
      q: socket.assigns.query,
      filter: socket.assigns.filter_option,
      limit: socket.assigns.limit,
      offset: new_offset
    }

    {:noreply, push_patch(socket, to: ~p"/case/?#{params}")}
  end

  @impl true
  def handle_event("change-limit", %{"pagination" => %{"limit" => limit_str}}, socket) do
    limit = String.to_integer(limit_str)

    params = %{
      q: socket.assigns.query,
      filter: socket.assigns.filter_option,
      limit: limit,
      offset: 0
    }

    {:noreply, push_patch(socket, to: ~p"/case/?#{params}")}
  end

  @impl true
  def handle_info(%{event: "create", payload: notification}, socket) do
    case = Ash.load!(notification.data, [:company])
    filter = socket.assigns.filter
    limit = socket.assigns.limit

    if socket.assigns.offset == 0 && case_matches_filter?(case, filter) do
      socket =
        if socket.assigns.page_results && length(socket.assigns.page_results.results) >= limit do
          last_case = List.last(socket.assigns.page_results.results)

          socket
          |> stream_delete(:cases, last_case)
          |> stream_insert(:cases, case, at: 0)
        else
          socket
        end

      {:noreply, socket}
    else
      socket = put_flash(socket, :info, "New case has been created: #{case.title}. Refresh to see updates.")
      {:noreply, socket}
    end
  end

  @impl true
  def handle_info(%{event: "update", payload: notification}, socket) do
    updated_case = Ash.load!(notification.data, [:company, assignee: [:full_name]])
    filter = socket.assigns.filter
    limit = socket.assigns.limit
    user = Ash.load!(socket.assigns.current_user, :super_admin?)

    socket =
      if Enum.any?(socket.assigns.page_results.results, fn case -> case.id == updated_case.id end) do
        stream_insert(socket, :cases, updated_case)
      else
        if socket.assigns.offset == 0 && case_matches_filter?(updated_case, filter) &&
             Incidents.can_get_case(user, updated_case) do
          if socket.assigns.page_results && length(socket.assigns.page_results.results) >= limit do
            last_case = List.last(socket.assigns.page_results.results)

            socket
            |> stream_delete(:cases, last_case)
            |> stream_insert(:cases, updated_case, at: 0)
          else
            stream_insert(socket, :cases, updated_case, at: 0)
          end
        else
          put_flash(socket, :info, "Case '#{updated_case.title}' has been updated. Refresh to see changes.")
        end
      end

    {:noreply, socket}
  end

  @impl true
  def handle_info(%{event: "assign_user", payload: notification}, socket) do
    updated_case = Ash.load!(notification.data, [:company, assignee: [:full_name]])
    filter = socket.assigns.filter
    limit = socket.assigns.limit
    user = Ash.load!(socket.assigns.current_user, :super_admin?)

    socket =
      if Enum.any?(socket.assigns.page_results.results, fn case -> case.id == updated_case.id end) do
        stream_insert(socket, :cases, updated_case)
      else
        if socket.assigns.offset == 0 && case_matches_filter?(updated_case, filter) &&
             Incidents.can_get_case(user, updated_case) do
          if socket.assigns.page_results && length(socket.assigns.page_results.results) >= limit do
            last_case = List.last(socket.assigns.page_results.results)

            socket
            |> stream_delete(:cases, last_case)
            |> stream_insert(:cases, updated_case, at: 0)
          else
            stream_insert(socket, :cases, updated_case, at: 0)
          end
        else
          put_flash(socket, :info, "Case '#{updated_case.title}' has been assigned. Refresh to see changes.")
        end
      end

    {:noreply, socket}
  end

  defp case_matches_filter?(case, %{status: [in: statuses]}) when is_list(statuses), do: case.status in statuses
  defp case_matches_filter?(_case, %{}), do: true
  defp case_matches_filter?(_case, _filter), do: false

  def pagination(assigns) do
    ~H"""
    <div class="flex items-center justify-between mt-6 gap-4">
      <div class="text-sm text-base-content/30">
        <%= if @page_results && @page_results.count do %>
          Showing {@offset + 1}-{min(@offset + @limit, @page_results.count)} of {@page_results.count} results
        <% end %>
      </div>

      <div class="flex gap-2">
        <.form :let={f} for={%{}} as={:pagination} phx-change="change-limit">
          <div class="flex items-center gap-2">
            <.input type="select" field={f[:limit]} options={[{"10", "10"}, {"25", "25"}, {"50", "50"}, {"100", "100"}]} value={@limit} class="select select-sm" />
          </div>
        </.form>

        <div class="join mt-1">
          <button class="join-item btn" phx-click="prev-page" disabled={@offset <= 0}>
            <.icon name="hero-chevron-left" />
          </button>

          <span class="join-item btn">Page {@current_page}</span>

          <button class="join-item btn" phx-click="next-page" disabled={@page_results && !@page_results.more?}>
            <.icon name="hero-chevron-right" />
          </button>
        </div>
      </div>
    </div>
    """
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
      _other -> :neutral
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

  defp get_filter_for_option("all"), do: %{}
  defp get_filter_for_option("open"), do: %{status: [in: [:new, :open, :reopened]]}
  defp get_filter_for_option("in_progress"), do: %{status: [in: [:in_progress]]}
  defp get_filter_for_option("pending"), do: %{status: [in: [:pending]]}
  defp get_filter_for_option("resolved"), do: %{status: [in: [:resolved]]}
  defp get_filter_for_option("closed"), do: %{status: [in: [:closed]]}
  defp get_filter_for_option("reopened"), do: %{status: [in: [:reopened]]}
  defp get_filter_for_option(_other), do: %{status: [in: [:closed, :resolved]]}

  defp time_ago(datetime) when is_struct(datetime) do
    now = DateTime.utc_now()
    diff_seconds = DateTime.diff(now, datetime, :second)

    cond do
      diff_seconds < 30 -> "just now"
      diff_seconds < 60 -> "#{diff_seconds} seconds ago"
      diff_seconds < 120 -> "1 minute ago"
      diff_seconds < 3600 -> "#{div(diff_seconds, 60)} minutes ago"
      diff_seconds < 7200 -> "1 hour ago"
      diff_seconds < 86_400 -> "#{div(diff_seconds, 3600)} hours ago"
      diff_seconds < 172_800 -> "1 day ago"
      diff_seconds < 2_592_000 -> "#{div(diff_seconds, 86_400)} days ago"
      diff_seconds < 5_184_000 -> "1 month ago"
      diff_seconds < 31_536_000 -> "#{div(diff_seconds, 2_592_000)} months ago"
      diff_seconds < 63_072_000 -> "1 year ago"
      true -> "#{div(diff_seconds, 31_536_000)} years ago"
    end
  end

  defp time_ago(_other), do: "unknown"
end
