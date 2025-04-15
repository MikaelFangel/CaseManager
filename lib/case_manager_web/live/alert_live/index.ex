defmodule CaseManagerWeb.AlertLive.Index do
  @moduledoc false
  use CaseManagerWeb, :live_view

  alias CaseManager.Incidents

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.split flash={@flash} search_placeholder="Search alerts">
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
        <.table id="alert" rows={@streams.alert_collection} row_click={fn {_id, alert} -> JS.push("show_alert", value: %{id: alert.id}) end} selectable={true} selected={@selected_alerts} on_toggle_selection={JS.push("toggle_selection")}>
          <:col :let={{_id, alert}} label="Company">{alert.company.name}</:col>
          <:col :let={{_id, alert}} label="Title">{alert.title}</:col>
          <:col :let={{_id, alert}} label="Risk Level">{alert.risk_level |> to_string() |> String.capitalize()}</:col>
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
                case @selected_alert.risk_level do
                  :critical -> :error
                  :high -> :warning
                  :medium -> :neutral
                  :low -> :success
                  :info -> :info
                end
              }
              class="ml-auto"
            >
              {@selected_alert.risk_level |> to_string() |> String.capitalize()}
            </.badge>
          </div>

          <div class="grid grid-cols-3 gap-4 items-center rounded-lg shadow p-4 mb-4 text-sm">
            <div class="relative group flex items-center space-x-2">
              <%= if @show_status_form do %>
                <.form for={@status_form} id="status-form" phx-submit="update_status" class="flex items-center space-x-2">
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
            <.form for={@comment_form} id="comment-form" phx-submit="add_comment">
              <.input field={@comment_form[:body]} type="textarea" placeholder="Add comment..." />
              <footer class="mt-2">
                <button class="btn btn-primary" phx-disable-with="Adding...">Add Comment</button>
              </footer>
            </.form>
          </div>

          <div class="divider"></div>
          <div class="flex items-center pb-2">
            <h3 class="font-medium text-md pr-4">Comments</h3>
            <.badge :if={@selected_alert.comments != []} type={:info}>{length(@selected_alert.comments || [])}</.badge>
          </div>
          <%= for comment <- @selected_alert.comments || [] do %>
            <div class="pb-2">
              <div class="flex items-center">
                <span class="font-bold text-sm pr-2">{comment.user.full_name}</span>
                <time class="text-xs text-gray-500">{comment.inserted_at}</time>
              </div>
              <p class="mt-1 text-sm">{comment.body}</p>
            </div>
          <% end %>
          <%= if @selected_alert.comments == [] do %>
            <p class="text-sm opacity-50">No comments available.</p>
          <% end %>
        <% else %>
          <div class="flex h-full items-center justify-center text-base-content/70">
            <p>Select an alert to view details</p>
          </div>
        <% end %>

        <.drawer title="New Case" open={@drawer_open} minimized={@drawer_minimized}>
          <.case_form form={@form} soc_options={@soc_options} />
        </.drawer>
      </:right>
    </Layouts.split>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    soc_options =
      Enum.map(
        Ash.load!(socket.assigns.current_user, :socs).socs,
        &{CaseManager.Organizations.get_soc!(&1.id).name, &1.id}
      )

    {:ok,
     socket
     |> assign(:page_title, "Listing Alert")
     |> assign(:selected_alerts, [])
     |> assign(:selected_alert, nil)
     |> assign(:drawer_open, false)
     |> assign(:drawer_minimized, false)
     |> assign(:show_status_form, false)
     |> assign(:comment_form, to_form(%{}))
     |> assign(:status_form, to_form(%{}))
     |> assign(:form, to_form(Incidents.form_to_create_case(actor: socket.assigns.current_user)))
     |> assign(:soc_options, soc_options)
     |> stream(:alert_collection, Incidents.list_alert!())}
  end

  @impl true
  def handle_params(%{"id" => id}, _uri, socket) do
    alert = Incidents.get_alert!(id)
    {:noreply, assign(socket, :selected_alert, alert)}
  end

  @impl true
  def handle_params(_params, _uri, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    alert = Incidents.get_alert!(id)
    {:ok, _} = Incidents.delete_alert(alert)

    {:noreply, stream_delete(socket, :alert_collection, alert)}
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
    {:noreply, assign(socket, :selected_alert, alert)}
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
        IO.inspect(form)
        {:noreply, assign(socket, :form, form)}
    end
  end

  def handle_event("validate_case", %{"form" => params}, socket) do
    form = AshPhoenix.Form.validate(socket.assigns.form, params)
    {:noreply, assign(socket, form: form)}
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

  defp status_options do
    [{"New", :new}, {"False positive", :false_positive}, {"Reviewed", :reviewed}, {"Linked to case", :linked_to_case}]
  end

  def case_form(assigns) do
    ~H"""
    <.form for={@form} id="case-form" phx-change="validate_case" phx-submit="save_case">
      <.input field={@form[:title]} type="text" label="Title" placeholder="Multiple accounts added to security group" />
      <.input field={@form[:soc_id]} type="select" label="SOC" prompt="Select SOC" options={@soc_options} />
      <.input field={@form[:risk_level]} type="select" prompt="Select risk" label="Risk Level" options={CaseManager.Incidents.RiskLevel.values() |> Enum.map(&{&1, &1})} />
      <.input field={@form[:description]} type="textarea" label="Description" placeholder="Multiple accounts were added to a security group, potentially indicating a security incident." />
      <footer>
        <.button phx-disable-with="Saving..." variant="primary">Save Case</.button>
      </footer>
    </.form>
    """
  end

  attr :title, :string
  attr :minimized, :boolean, default: false
  attr :open, :boolean, default: false
  slot :inner_block

  def drawer(assigns) do
    ~H"""
    <%= if @open do %>
      <div class={"fixed bottom-0 right-0 w-full max-w-md #{if @minimized, do: "h-14", else: "h-3/5"} bg-base-200 shadow-xl overflow-y-scroll"}>
        <div class="h-full flex flex-col py-4">
          <div class="px-4 sm:px-6 flex justify-between items-center">
            <h2 class="text-lg font-medium">
              {@title}
            </h2>
            <div class="flex items-center">
              <button phx-click="toggle_minimize" class="hover:bg-secondary/10 rounded-full w-8 h-8 flex items-center justify-center">
                <%= if @minimized do %>
                  <.icon name="hero-arrow-up" />
                <% else %>
                  <.icon name="hero-minus-solid" />
                <% end %>
              </button>
              <button phx-click="close_drawer" class="hover:bg-error/50 rounded-full w-8 h-8 flex items-center justify-center ml-2">
                <.icon name="hero-x-mark-solid" />
              </button>
            </div>
          </div>
          <div class="mt-6 relative flex-1 px-4 sm:px-6">
            <%= unless @minimized do %>
              {render_slot(@inner_block)}
            <% end %>
          </div>
        </div>
      </div>
    <% end %>
    """
  end
end
