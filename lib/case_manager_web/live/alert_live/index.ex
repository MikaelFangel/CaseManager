defmodule CaseManagerWeb.AlertLive.Index do
  @moduledoc false
  use CaseManagerWeb, :live_view

  alias CaseManager.Incidents

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.split flash={@flash} search_placeholder="Search alerts" search_value={@query} user_roles={@user_roles} show_mobile_panel={@show_mobile_panel}>
      <:top>
        <.header class="h-12">
          <:actions>
            <.button :if={length(@selected_alerts) > 0} variant="primary" phx-click="open_drawer">
              Create case for {length(@selected_alerts)} alerts
            </.button>
          </:actions>
        </.header>
      </:top>
      <:left>
        <%= if @loading && @page == 1 do %>
          <div class="flex justify-center items-center p-8">
            <span class="loading loading-spinner loading-md"></span>
            <span class="ml-2">Loading alerts...</span>
          </div>
        <% else %>
          <div>
            <div
              id="alerts"
              phx-update="stream"
              phx-viewport-top={@page > 1 && JS.push("prev-page", page_loading: true)}
              phx-viewport-bottom={!@end_of_timeline? && JS.push("next-page", page_loading: true)}
              class={[
                if(@end_of_timeline?, do: "pb-4", else: "pb-8"),
                if(@page == 1, do: "pt-4", else: "pt-8")
              ]}
            >
              <.table id="alert" rows={@streams.alert_collection} row_click={fn {_id, alert} -> JS.push("show_alert", value: %{id: alert.id}) end} selectable={true} selected={@selected_alerts} on_toggle_selection={JS.push("toggle_selection")}>
                <:col :let={{_id, alert}} label="Company">{alert.company.name}</:col>
                <:col :let={{_id, alert}} label="Title">{alert.title}</:col>
                <:col :let={{_id, alert}} label="Severity">{alert.severity |> to_string() |> String.capitalize()}</:col>
                <:col :let={{_id, alert}}>
                  <.status type={
                    case alert.status do
                      :new -> :info
                      :reviewed -> :warning
                      :false_positive -> nil
                      :linked_to_case -> nil
                      _ -> :error
                    end
                  } />
                </:col>
              </.table>
            </div>

            <%= if @end_of_timeline? do %>
              <div class="mt-5 text-center text-base-content/50">
                🎉 You've reached the end of the alerts 🎉
              </div>
            <% end %>
          </div>
        <% end %>
      </:left>

      <:right>
        <%= if @selected_alert do %>
          <div class="flex justify-between">
            <.header>
              {@selected_alert.title}
              <:subtitle>{@selected_alert.company.name}</:subtitle>
            </.header>
            <.badge
              type={
                case @selected_alert.severity do
                  :critical -> :error
                  :high -> :warning
                  :medium -> :neutral
                  :low -> :success
                  :info -> :info
                end
              }
              class="ml-auto"
            >
              {@selected_alert.severity |> to_string() |> String.capitalize()}
            </.badge>
          </div>

          <div class="grid grid-cols-3 gap-4 items-center rounded-lg shadow p-4 mb-4 text-sm">
            <div class="relative group flex items-center space-x-2">
              <%= if @show_status_form do %>
                <.form for={@status_form} id="status-form" phx-change="validate_status" phx-submit="update_status" class="flex items-center space-x-2">
                  <div>
                    <.input field={@status_form[:status]} type="select" options={status_options()} />
                    <.button variant="primary" phx-disable-with="Updating...">Update</.button>
                    <.button type="button" phx-click="toggle_status_form">Cancel</.button>
                  </div>
                </.form>
              <% else %>
                <button phx-click="toggle_status_form" class="flex items-center space-x-2">
                  <span>
                    {@selected_alert.status |> to_string |> String.split("_") |> Enum.join(" ") |> String.capitalize()}
                  </span>
                  <.icon name="hero-pencil-square" class="hidden group-hover:block cursor-pointer size-3" />
                </button>
              <% end %>
            </div>
            <div class="text-center">
              {@selected_alert.creation_time}
            </div>
            <div class="text-right">
              <.link href={@selected_alert.link} class="text-info hover:underline">
                <.icon name="hero-link" class="size-3" /> Alert link
              </.link>
            </div>
          </div>

          <div class="mb-8">
            <h3 class="font-medium text-lg mb-2">Description</h3>
            <div class="prose">
              <p>{@selected_alert.description || "No description provided."}</p>
            </div>
          </div>

          <%= for {case, index} <- Enum.with_index(@selected_alert.cases || []) do %>
            <div class="collapse border border-base-300 bg-base-100">
              <input :if={!@drawer_open} type="radio" name="case-accordion" id={"case-#{index}"} />
              <div class="collapse-title text-sm">
                {case.title}
                <.badge type={status_to_badge_type(case.status)} modifier={:outline}>
                  {case.status |> to_string() |> String.split("_") |> Enum.join(" ") |> String.capitalize()}
                </.badge>
              </div>
              <div class="collapse-content flex flex-col text-xs">
                <p class="mb-4">{case.description}</p>
                <.button navigate={~p"/case/#{case.id}"}>Open</.button>
              </div>
            </div>
          <% end %>
          <%= if @selected_alert.cases == [] do %>
            <div class="p-4 text-sm text-gray-500">No linked cases available.</div>
          <% end %>

          <div class="mt-4">
            <.form for={@comment_form} id="comment-form" phx-change="validate_comment" phx-submit="add_comment">
              <.input field={@comment_form[:body]} type="textarea" placeholder="Add comment..." />
              <footer class="mt-2">
                <button class="btn btn-primary" phx-disable-with="Adding...">Add Comment</button>
              </footer>
            </.form>
          </div>

          <Layouts.divider />
          <div class="flex items-center pb-2">
            <h3 class="font-medium text-md pr-4">Comments</h3>
            <.badge :if={@selected_alert.comments != []} type={:info}>{length(@selected_alert.comments || [])}</.badge>
          </div>
          <div id="comments-stream" phx-update="stream">
            <%= for {id, comment} <- @streams.comments do %>
              <div id={id} class="pb-2">
                <div class="flex items-center">
                  <span class="font-bold text-sm pr-2">{comment.user.full_name}</span>
                  <time class="text-xs text-gray-500">{comment.inserted_at}</time>
                </div>
                <p class="mt-1 text-sm">{comment.body}</p>
              </div>
            <% end %>
          </div>
          <%= if @selected_alert.comments == [] do %>
            <p class="text-sm opacity-50">No comments available.</p>
          <% end %>
        <% else %>
          <div class="flex h-full items-center justify-center text-base-content/70">
            <p>Select an alert to view details</p>
          </div>
        <% end %>

        <.drawer title="New Case" open={@drawer_open} minimized={@drawer_minimized}>
          <.case_form form={@form} soc_options={@soc_options} selected_alerts={@selected_alerts} />
        </.drawer>
      </:right>
    </Layouts.split>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    user = Ash.load!(socket.assigns.current_user, [:companies, :socs, :soc_roles, :company_roles, :super_admin?])

    if connected?(socket) do
      if user.super_admin? do
        CaseManagerWeb.Endpoint.subscribe("alert")
      end

      Enum.each(user.companies, fn company -> CaseManagerWeb.Endpoint.subscribe("alert:#{company.id}") end)
      Enum.each(user.socs, fn soc -> CaseManagerWeb.Endpoint.subscribe("alert:#{soc.id}") end)
    end

    soc_options =
      Enum.map(
        Ash.load!(socket.assigns.current_user, :socs).socs,
        &{CaseManager.Organizations.get_soc!(&1.id).name, &1.id}
      )

    {:ok,
     socket
     |> assign(:page_title, "Listing Alerts")
     |> assign(:user_roles, user.soc_roles ++ user.company_roles)
     |> assign(:selected_alerts, [])
     |> assign(:selected_alert, nil)
     |> assign(:drawer_open, false)
     |> assign(:drawer_minimized, false)
     |> assign(:show_status_form, false)
     |> assign(:show_mobile_panel, false)
     |> assign(:form, to_form(Incidents.form_to_create_case(actor: socket.assigns.current_user)))
     |> assign(:soc_options, soc_options)
     |> assign(:page, 1)
     |> assign(:per_page, 20)
     |> assign(:query, "")
     |> assign(:loading, false)
     |> assign(:end_of_timeline?, false)
     |> assign(:current_alert_subscription, nil)}
  end

  @impl true
  def handle_params(params, _uri, socket) do
    query = Map.get(params, "q", "")
    id = Map.get(params, "id")

    # Load the selected alert if there's an ID in params
    selected_alert =
      if id do
        try do
          Incidents.get_alert!(id, load: [:cases, :company, comments: [user: [:full_name]]])
        rescue
          _error -> nil
        end
      end

    socket =
      if connected?(socket) do
        if socket.assigns.current_alert_subscription do
          CaseManagerWeb.Endpoint.unsubscribe("comment:#{socket.assigns.current_alert_subscription}:comments")
        end

        if id do
          CaseManagerWeb.Endpoint.subscribe("comment:#{id}:comments")
        end

        socket
      else
        socket
      end

    socket =
      socket
      |> assign(:query, query)
      |> assign(:selected_alert, selected_alert)
      |> assign(
        :comment_form,
        if(selected_alert,
          do: to_form(Incidents.form_to_add_comment_to_alert(selected_alert, actor: socket.assigns.current_user)),
          else: to_form(%{})
        )
      )
      |> assign(
        :status_form,
        if(selected_alert, do: to_form(Incidents.form_to_change_alert_status(selected_alert)), else: to_form(%{}))
      )
      |> assign(:show_status_form, false)
      |> assign(:page, 1)
      |> assign(:end_of_timeline?, false)
      |> assign(:current_alert_subscription, id)
      |> stream(:alert_collection, [], reset: true)
      |> stream(:comments, if(selected_alert, do: selected_alert.comments || [], else: []), reset: true)

    # Apply pagination with the search query after assigns are set
    socket = paginate_alerts(socket, 1)

    {:noreply, socket}
  end

  @impl true
  def handle_event("next-page", _params, socket) do
    {:noreply, paginate_alerts(socket, socket.assigns.page + 1)}
  end

  @impl true
  def handle_event("prev-page", %{"_overran" => true}, socket) do
    {:noreply, paginate_alerts(socket, 1)}
  end

  @impl true
  def handle_event("prev-page", _params, socket) do
    if socket.assigns.page > 1 do
      {:noreply, paginate_alerts(socket, socket.assigns.page - 1)}
    else
      {:noreply, socket}
    end
  end

  @impl true
  def handle_event("search", params, socket) do
    search = params["query"] || params["q"] || params[:query] || params[:q] || ""
    search_params = %{q: search}

    search_params =
      if socket.assigns.selected_alert,
        do: Map.put(search_params, :id, socket.assigns.selected_alert.id),
        else: search_params

    {:noreply, push_patch(socket, to: ~p"/alert/?#{search_params}")}
  end

  @impl true
  def handle_event("toggle_selection", %{"id" => id}, socket) do
    selected_alerts = socket.assigns.selected_alerts

    updated_selected =
      if id in selected_alerts do
        List.delete(selected_alerts, id)
      else
        [id | selected_alerts]
      end

    {:noreply, assign(socket, :selected_alerts, updated_selected)}
  end

  @impl true
  def handle_event("show_alert", %{"id" => id}, socket) do
    alert = Incidents.get_alert!(id, load: [:cases, :company, comments: [user: [:full_name]]])

    # Handle comment subscription changes
    socket =
      if connected?(socket) do
        # Unsubscribe from previous alert comments if any
        if socket.assigns.current_alert_subscription do
          CaseManagerWeb.Endpoint.unsubscribe("comment:#{socket.assigns.current_alert_subscription}:comments")
        end

        # Subscribe to new alert comments
        CaseManagerWeb.Endpoint.subscribe("comment:#{id}:comments")

        socket
      else
        socket
      end

    socket =
      socket
      |> assign(
        :comment_form,
        to_form(Incidents.form_to_add_comment_to_alert(alert, actor: socket.assigns.current_user))
      )
      |> assign(
        :status_form,
        to_form(Incidents.form_to_change_alert_status(alert))
      )
      |> assign(:selected_alert, alert)
      |> assign(:current_alert_subscription, id)
      |> stream(:comments, alert.comments, reset?: true)
      |> assign(:show_mobile_panel, true)

    params = %{q: socket.assigns.query}
    params = Map.put(params, :id, id)

    {:noreply, push_patch(socket, to: ~p"/alert/?#{params}")}
  end

  @impl true
  def handle_event("toggle_status_form", _params, socket) do
    {:noreply, assign(socket, :show_status_form, !socket.assigns.show_status_form)}
  end

  @impl true
  def handle_event("open_drawer", _params, socket) do
    socket =
      socket
      |> assign(:drawer_open, true)
      |> assign(:drawer_minimized, false)

    {:noreply, socket}
  end

  @impl true
  def handle_event("close_drawer", _params, socket) do
    socket =
      socket
      |> assign(:drawer_open, false)
      |> assign(:drawer_minimized, false)

    {:noreply, socket}
  end

  @impl true
  def handle_event("toggle_minimize", _params, socket) do
    {:noreply, assign(socket, :drawer_minimized, !socket.assigns.drawer_minimized)}
  end

  @impl true
  def handle_event("clear_selected_alert", _params, socket) do
    params = %{q: socket.assigns.query}
    {:noreply, push_patch(socket, to: ~p"/alert/?#{params}")}
  end

  @impl true
  def handle_event("add_comment", %{"form" => form}, socket) do
    case AshPhoenix.Form.submit(socket.assigns.comment_form, params: form, actor: socket.assigns.current_user) do
      {:ok, _comment} ->
        # Reset form to clear textarea
        socket =
          assign(
            socket,
            :comment_form,
            to_form(
              Incidents.form_to_add_comment_to_alert(socket.assigns.selected_alert, actor: socket.assigns.current_user)
            )
          )

        {:noreply, socket}

      {:error, form} ->
        {:noreply, assign(socket, :comment_form, form)}
    end
  end

  @impl true
  def handle_event("update_status", %{"form" => form}, socket) do
    case AshPhoenix.Form.submit(socket.assigns.status_form, params: form) do
      {:ok, _status} ->
        {:noreply,
         socket |> put_flash(:info, gettext("Status updated successfully.")) |> assign(:show_status_form, false)}

      {:error, form} ->
        {:noreply, assign(socket, :status_for, form)}
    end
  end

  @impl true
  def handle_event("save_case", %{"form" => form}, socket) do
    alert =
      socket.assigns.selected_alerts
      |> hd()
      |> String.replace("alert_collection-", "")
      |> CaseManager.Incidents.get_alert!()

    form =
      form
      |> Map.put("alerts", Enum.map(socket.assigns.selected_alerts, &String.replace(&1, "alert_collection-", "")))
      |> Map.put("company_id", alert.company_id)

    case AshPhoenix.Form.submit(socket.assigns.form, params: form) do
      {:ok, case} ->
        {:noreply,
         socket
         |> put_flash(:info, gettext("Case created successfully."))
         |> push_navigate(to: ~p"/case/#{case.id}")}

      {:error, form} ->
        {:noreply, assign(socket, :form, form)}
    end
  end

  def handle_event("validate_case", %{"form" => params}, socket) do
    form = AshPhoenix.Form.validate(socket.assigns.form, params)
    {:noreply, assign(socket, form: form)}
  end

  def handle_event("validate_comment", %{"form" => params}, socket) do
    form = AshPhoenix.Form.validate(socket.assigns.comment_form, params)
    {:noreply, assign(socket, comment_form: form)}
  end

  @impl true
  def handle_event("validate_status", %{"form" => params}, socket) do
    form = AshPhoenix.Form.validate(socket.assigns.status_form, params)
    {:noreply, assign(socket, :status_form, form)}
  end

  @impl true
  def handle_event("toggle_mobile_panel", _params, socket) do
    {:noreply, assign(socket, :show_mobile_panel, !socket.assigns.show_mobile_panel)}
  end

  defp paginate_alerts(socket, new_page) when new_page >= 1 do
    %{per_page: per_page, page: cur_page, query: query} = socket.assigns
    user = Ash.load!(socket.assigns.current_user, :super_admin?)

    try do
      alerts =
        Incidents.search_alerts!(
          query,
          page: [limit: per_page, offset: (new_page - 1) * per_page],
          actor: user
        ).results

      {alerts, at, limit} =
        if new_page >= cur_page do
          {alerts, -1, per_page * 3 * -1}
        else
          {Enum.reverse(alerts), 0, per_page * 3}
        end

      case alerts do
        [] ->
          assign(socket, end_of_timeline?: at == -1)

        [_head | _tail] = alerts ->
          socket
          |> assign(end_of_timeline?: false)
          |> assign(:page, new_page)
          |> stream(:alert_collection, alerts, at: at, limit: limit)
      end
    rescue
      error ->
        socket
        |> assign(:loading, false)
        |> put_flash(:error, "Failed to load alerts: #{inspect(error)}")
    end
  end

  def handle_info(%{topic: "alert" <> _, event: "create", payload: notification}, socket) do
    alert = Ash.load!(notification.data, [:company])

    # Only add new alerts when viewing the first page to prevent jumping
    if socket.assigns.page == 1 do
      socket = stream_insert(socket, :alert_collection, alert, at: 0, limit: socket.assigns.per_page * 3 * -1)

      {:noreply, socket}
    else
      # If not on first page, show a flash message instead
      socket = put_flash(socket, :info, "New alert has been created: #{alert.title}. Refresh to see updates.")
      {:noreply, socket}
    end
  end

  @impl true
  def handle_info(%{topic: "alert" <> _, event: "update", payload: notification}, socket) do
    updated_alert = Ash.load!(notification.data, [:company])

    socket = stream_insert(socket, :alert_collection, updated_alert)

    socket =
      if socket.assigns.selected_alert && socket.assigns.selected_alert.id == updated_alert.id do
        updated_alert_with_relations =
          Incidents.get_alert!(updated_alert.id, load: [:company, :cases, comments: [user: [:full_name]]])

        assign(socket, :selected_alert, updated_alert_with_relations)
      else
        socket
      end

    {:noreply, socket}
  end

  def handle_info(%{topic: "comment:" <> _, event: "create", payload: %{data: comment}}, socket) do
    if socket.assigns.selected_alert && comment.alert_id == socket.assigns.selected_alert.id do
      comment_with_user = Ash.load!(comment, user: [:full_name])
      socket = stream_insert(socket, :comments, comment_with_user, at: 0)
      {:noreply, socket}
    else
      {:noreply, socket}
    end
  end

  defp status_options do
    [
      {"New", "new"},
      {"Reviewed", "reviewed"},
      {"False Positive", "false_positive"},
      {"Linked to Case", "linked_to_case"}
    ]
  end

  def case_form(assigns) do
    ~H"""
    <.form for={@form} id="case-form" phx-change="validate_case" phx-submit="save_case">
      <.input field={@form[:title]} type="text" label="Title" required />
      <.input field={@form[:description]} type="textarea" label="Description" />
      <.input field={@form[:soc_id]} type="select" label="SOC" options={@soc_options} prompt="Select SOC" required />
      <.input field={@form[:severity]} type="select" label="Severity" options={CaseManager.Incidents.Severity.values() |> Enum.map(&{&1 |> to_string() |> String.capitalize(), &1})} prompt="Select Severity" />

      <div class="mt-4 p-3 bg-base-200 rounded-lg">
        <h4 class="font-medium mb-2">Selected Alerts (<span class="badge badge-primary">{length(@selected_alerts || [])}</span>)</h4>
        <%= if length(@selected_alerts || []) > 0 do %>
          <div class="text-sm text-base-content/70 mb-2">
            This case will be linked to the selected {length(@selected_alerts)} alert(s).
          </div>
          <div class="text-xs text-base-content/50">
            Alert IDs: {Enum.join(@selected_alerts || [], ", ")}
          </div>
        <% else %>
          <div class="text-sm text-warning">
            No alerts selected. Please select alerts first.
          </div>
        <% end %>
      </div>

      <footer class="mt-4">
        <button class={["btn btn-primary", if(length(@selected_alerts || []) == 0, do: "btn-disabled", else: "")]} phx-disable-with="Creating..." disabled={length(@selected_alerts || []) == 0}>
          Create Case
        </button>
        <button type="button" class="btn" phx-click="close_drawer">Cancel</button>
      </footer>
    </.form>
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
end
