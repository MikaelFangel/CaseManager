defmodule CaseManagerWeb.SOCLive.Index do
  @moduledoc false
  use CaseManagerWeb, :live_view

  alias CaseManager.Organizations

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:drawer_open, false)
      |> assign(:drawer_minimized, false)
      |> assign(:selected_soc, nil)
      |> assign(:search_query, "")
      |> assign(:soc_form, to_form(Organizations.form_to_create_soc()))

    {:ok, socket}
  end

  @impl true
  def handle_params(params, _uri, socket) do
    search_query = Map.get(params, "query", "")

    socket =
      socket
      |> assign(:search_query, search_query)
      |> stream(:socs, Organizations.search_soc!(search_query), reset: true)

    {:noreply, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.split flash={@flash} search_placeholder="Search SOCs" search_value={@search_query}>
      <:top>
        <.header class="h-12">
          <:actions>
            <.button variant="primary" phx-click="open_create_drawer">
              <.icon name="hero-plus" class="size-4 mr-1" /> New SOC
            </.button>
          </:actions>
        </.header>
      </:top>
      <:left>
        <div class="flex flex-col h-full">
          <div class="flex-grow overflow-auto">
            <.table id="soc" rows={@streams.socs} row_click={fn {_id, soc} -> JS.push("show_soc", value: %{id: soc.id}) end}>
              <:col :let={{_id, soc}} label="Name">{soc.name}</:col>
            </.table>
          </div>
        </div>
      </:left>
      <:right>
        <.soc_details soc={@selected_soc} />
        <.drawer title="Create New SOC" open={@drawer_open} minimized={@drawer_minimized} height="1/3">
          <.soc_form form={@soc_form} />
        </.drawer>
      </:right>
    </Layouts.split>
    """
  end

  @impl true
  def handle_event("open_create_drawer", _params, socket) do
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
    socket = assign(socket, :drawer_minimized, !socket.assigns.drawer_minimized)
    {:noreply, socket}
  end

  @impl true
  def handle_event("create_soc", %{"form" => params}, socket) do
    case AshPhoenix.Form.submit(socket.assigns.soc_form, params: params) do
      {:ok, soc} ->
        socket =
          socket
          |> put_flash(:info, "SOC created successfully.")
          |> assign(:drawer_open, false)
          |> stream_insert(:socs, soc)

        {:noreply, socket}

      {:error, form} ->
        socket = assign(socket, :soc_form, form)
        {:noreply, socket}
    end
  end

  @impl true
  def handle_event("validate_soc", %{"form" => params}, socket) do
    form = AshPhoenix.Form.validate(socket.assigns.soc_form, params)
    socket = assign(socket, :soc_form, form)
    {:noreply, socket}
  end

  @impl true
  def handle_event("search", %{"query" => query}, socket) do
    {:noreply, push_patch(socket, to: ~p"/soc?q=#{query}")}
  end

  @impl true
  def handle_event("show_soc", %{"id" => id}, socket) do
    soc = Organizations.get_soc!(id)

    socket = assign(socket, :selected_soc, soc)

    {:noreply, socket}
  end

  defp list_socs do
    Organizations.list_soc!()
  end

  attr :soc, :any, default: nil

  defp soc_details(assigns) do
    ~H"""
    <%= if @soc do %>
      <div class="py-4 px-2">
        <h2 class="text-xl font-bold mb-4">{@soc.name}</h2>
        <.soc_details_card soc={@soc} />
      </div>
    <% else %>
      <div class="flex h-full items-center justify-center text-base-content/70">
        <p>Select a SOC to view details</p>
      </div>
    <% end %>
    """
  end

  attr :soc, :any, required: true

  defp soc_details_card(assigns) do
    ~H"""
    <div class="rounded-lg shadow-sm border p-4">
      <div class="flex justify-between items-center mb-3">
        <h3 class="text-sm font-medium text-base-content/70">SOC Details</h3>
      </div>
      <div class="space-y-3">
        <div class="flex items-center p-2">
          <div class="flex-1">
            <div class="text-sm text-base-content/70">Name</div>
            <div class="font-medium">{@soc.name}</div>
          </div>
        </div>
        <div class="flex items-center p-2">
          <div class="flex-1">
            <div class="text-sm text-base-content/70">ID</div>
            <div class="font-medium text-sm font-mono">{@soc.id}</div>
          </div>
        </div>
      </div>
    </div>
    """
  end

  attr :form, :any, required: true

  defp soc_form(assigns) do
    ~H"""
    <div class="space-y-6">
      <.form for={@form} id="soc-form" phx-change="validate_soc" phx-submit="create_soc">
        <div class="mb-6">
          <.input field={@form[:name]} type="text" label="SOC Name" placeholder="Security Operations Center Name" />
        </div>

        <div class="flex justify-end space-x-3">
          <.button type="submit" variant="primary">Create SOC</.button>
        </div>
      </.form>
    </div>
    """
  end
end
