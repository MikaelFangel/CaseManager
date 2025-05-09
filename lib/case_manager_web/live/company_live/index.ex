defmodule CaseManagerWeb.CompanyLive.Index do
  @moduledoc false
  use CaseManagerWeb, :live_view

  alias CaseManager.Organizations

  @impl true
  def mount(_params, _session, socket) do
    user = Ash.load!(socket.assigns.current_user, :socs)

    socket =
      socket
      |> assign(:selected_companies, [])
      |> assign(:company_shared_with, [])
      |> assign(:drawer_open, false)
      |> assign(:drawer_minimized, false)
      |> assign(:drawer_type, :share)
      |> assign(:selected_company, nil)
      |> assign(:active_tab, :all)
      |> assign(:user_socs, user.socs)
      |> assign(:search_query, "")
      |> assign(:company_form, to_form(Organizations.form_to_create_company()))

    {:ok, socket}
  end

  @impl true
  def handle_params(params, _uri, socket) do
    tab = params |> Map.get("tab", "all") |> String.to_existing_atom()
    search_query = Map.get(params, "query", "")
    companies = get_companies_for_tab(tab, socket.assigns.current_user, search_query)

    socket =
      socket
      |> assign(:active_tab, tab)
      |> assign(:search_query, search_query)
      |> stream(:companies, companies, reset: true)

    {:noreply, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.split flash={@flash} search_placeholder="Search companies">
      <:top>
        <.header class="h-12">
          <:actions>
            <div class="flex space-x-3">
              <.button :if={length(@selected_companies) > 0} variant="primary" phx-click="open_share_drawer">
                Share {length(@selected_companies)} companies
              </.button>
              <.button variant="primary" phx-click="open_create_drawer">
                <.icon name="hero-plus" class="size-4 mr-1" /> New Company
              </.button>
            </div>
          </:actions>
        </.header>
      </:top>
      <:left>
        <div class="flex flex-col h-full">
          <div class="flex-grow overflow-auto">
            <.table id="company" rows={@streams.companies} row_click={fn {_id, company} -> JS.push("show_company", value: %{id: company.id}) end} selectable={@active_tab == :managed} selected={@selected_companies} on_toggle_selection={JS.push("toggle_selection")}>
              <:col :if={@active_tab != :managed} class="w-12">
                <div class="opacity-40">
                  <.icon name="hero-minus" />
                </div>
              </:col>
              <:col :let={{_id, company}} label="Name">{company.name}</:col>
            </.table>
          </div>

          <.tabs active={@active_tab} />
        </div>
      </:left>
      <:right>
        <.company_details company={@selected_company} shared_with={@company_shared_with} />
        <.drawer title={if @drawer_type == :share, do: "Share Companies", else: "Create New Company"} open={@drawer_open} minimized={@drawer_minimized} height="1/3">
          <%= if @drawer_type == :share do %>
            <.share_form socs={@user_socs} selected_companies={@selected_companies} />
          <% else %>
            <.company_form form={@company_form} socs={@user_socs} />
          <% end %>
        </.drawer>
      </:right>
    </Layouts.split>
    """
  end

  @impl true
  def handle_event("set_tab", %{"tab" => tab}, socket) do
    {:noreply, push_patch(socket, to: ~p"/company?tab=#{tab}")}
  end

  @impl true
  def handle_event("toggle_selection", %{"id" => id}, socket) do
    if socket.assigns.active_tab == :managed do
      selected_companies = socket.assigns.selected_companies

      updated_selected =
        if id in selected_companies do
          List.delete(selected_companies, id)
        else
          [id | selected_companies]
        end

      socket = assign(socket, :selected_companies, updated_selected)
      {:noreply, socket}
    else
      {:noreply, socket}
    end
  end

  @impl true
  def handle_event("open_share_drawer", _params, socket) do
    socket =
      socket
      |> assign(:drawer_open, true)
      |> assign(:drawer_minimized, false)
      |> assign(:drawer_type, :share)

    {:noreply, socket}
  end

  @impl true
  def handle_event("open_create_drawer", _params, socket) do
    socket =
      socket
      |> assign(:drawer_open, true)
      |> assign(:drawer_minimized, false)
      |> assign(:drawer_type, :create)

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
  def handle_event("share_companies", %{"share_form" => form_data}, socket) do
    soc = Ash.get!(CaseManager.Organizations.SOC, form_data["soc_id"])
    company_ids = Enum.map(socket.assigns.selected_companies, &String.replace_prefix(&1, "companies-", ""))

    case Organizations.share_companies_with_soc(soc, company_ids) do
      {:ok, _result} ->
        socket =
          socket
          |> put_flash(:info, "Companies successfully shared with SOC")
          |> assign(:drawer_open, false)
          |> assign(:selected_companies, [])

        {:noreply, socket}

      {:error, _changeset} ->
        socket = put_flash(socket, :error, "Unable to share companies. Please try again.")
        {:noreply, socket}
    end
  end

  @impl true
  def handle_event("create_company", %{"form" => params}, socket) do
    case AshPhoenix.Form.submit(socket.assigns.company_form, params: params) do
      {:ok, company} ->
        socket =
          socket
          |> put_flash(:info, "Company created successfully.")
          |> assign(:drawer_open, false)
          |> stream_insert(:companies, company)

        {:noreply, socket}

      {:error, form} ->
        socket = assign(socket, :company_form, form)
        {:noreply, socket}
    end
  end

  @impl true
  def handle_event("validate_company", %{"form" => params}, socket) do
    form = AshPhoenix.Form.validate(socket.assigns.company_form, params)
    socket = assign(socket, :company_form, form)
    {:noreply, socket}
  end

  @impl true
  def handle_event("search", %{"query" => query}, socket) do
    {:noreply, push_patch(socket, to: ~p"/company?tab=#{socket.assigns.active_tab}&query=#{query}")}
  end

  @impl true
  def handle_event("show_company", %{"id" => id}, socket) do
    company = Organizations.get_company!(id, load: [:soc_accesses])
    user = Ash.load!(socket.assigns.current_user, :socs)

    shared_with = Enum.reject(company.soc_accesses, fn soc -> soc.id in user.socs end)

    socket =
      socket
      |> assign(:selected_company, company)
      |> assign(:company_shared_with, shared_with)

    {:noreply, socket}
  end

  defp get_companies_for_tab(:all, user, search_query) do
    get_companies_for_tab(:managed, user, search_query) ++ get_companies_for_tab(:shared, user, search_query)
  end

  defp get_companies_for_tab(:managed, user, search_query) do
    user = Ash.load!(user, :socs)

    user.socs
    |> Enum.flat_map(fn soc ->
      if search_query == "" do
        Organizations.get_managed_companies!(soc.id)
      else
        search_query
        |> Organizations.search_company!()
        |> Enum.filter(fn company -> company.soc_id == soc.id end)
      end
    end)
    |> Enum.uniq_by(fn company -> company.id end)
  end

  defp get_companies_for_tab(:shared, user, search_query) do
    user = Ash.load!(user, socs: [:company_accesses])

    user.socs
    |> Enum.flat_map(fn soc ->
      if search_query == "" do
        soc.company_accesses
      else
        companies = Organizations.search_company!(search_query)
        company_access_ids = Enum.map(soc.company_accesses, & &1.id)
        Enum.filter(companies, fn company -> company.id in company_access_ids end)
      end
    end)
    |> Enum.uniq_by(fn company -> company.id end)
  end

  attr :active, :atom, required: true

  defp tabs(assigns) do
    ~H"""
    <div class="mt-auto pt-4 pb-2 flex justify-center">
      <div role="tablist" class="tabs tabs-box">
        <a role="tab" class={"tab #{if @active == :all, do: "tab-active"}"} phx-click="set_tab" phx-value-tab="all">All</a>
        <a role="tab" class={"tab #{if @active == :managed, do: "tab-active"}"} phx-click="set_tab" phx-value-tab="managed">Managed</a>
        <a role="tab" class={"tab #{if @active == :shared, do: "tab-active"}"} phx-click="set_tab" phx-value-tab="shared">Shared with You</a>
      </div>
    </div>
    """
  end

  attr :company, :any, default: nil
  attr :shared_with, :list, default: []

  defp company_details(assigns) do
    ~H"""
    <%= if @company do %>
      <div class="py-4 px-2">
        <h2 class="text-xl font-bold mb-4">{@company.name}</h2>
        <.shared_with_card companies={@shared_with} />
      </div>
    <% else %>
      <div class="flex h-full items-center justify-center text-base-content/70">
        <p>Select a company to view details</p>
      </div>
    <% end %>
    """
  end

  attr :companies, :list, required: true

  defp shared_with_card(assigns) do
    ~H"""
    <div class="rounded-lg shadow-sm border p-4">
      <div class="flex justify-between items-center mb-3">
        <h3 class="text-sm font-medium text-base-content/70">Shared with SOCs</h3>
        <.badge :if={@companies != []}>
          {length(@companies)}
        </.badge>
      </div>

      <%= if @companies != [] do %>
        <div class="space-y-3">
          <%= for company <- @companies do %>
            <div class="flex items-center p-2 rounded-md hover:bg-base-200 transition-colors">
              <div class="flex-1">
                <div class="font-medium">{company.name}</div>
              </div>
            </div>
          <% end %>
        </div>
      <% else %>
        <div class="py-8 flex flex-col items-center text-center text-base-content/60">
          <p>This company is not shared with any SOCs yet</p>
        </div>
      <% end %>
    </div>
    """
  end

  attr :socs, :list, required: true
  attr :selected_companies, :list, required: true

  defp share_form(assigns) do
    ~H"""
    <div class="space-y-6">
      <.form for={%{}} as={:share_form} phx-submit="share_companies">
        <div class="mb-6">
          <label class="block text-sm font-medium mb-2">Select SOC to share with:</label>
          <select name="share_form[soc_id]" class="select select-bordered w-full" required>
            <option value="">Choose a SOC...</option>
            <%= for soc <- @socs do %>
              <option value={soc.id}>{soc.name}</option>
            <% end %>
          </select>
        </div>

        <div class="flex justify-end space-x-3">
          <.button type="submit" variant="primary">Share Companies</.button>
        </div>
      </.form>
    </div>
    """
  end

  attr :form, :any, required: true
  attr :socs, :list, required: true

  defp company_form(assigns) do
    ~H"""
    <div class="space-y-6">
      <.form for={@form} id="company-form" phx-change="validate_company" phx-submit="create_company">
        <div class="mb-6">
          <.input field={@form[:name]} type="text" label="Company Name" placeholder="Acme Corporation" />
          <.input field={@form[:soc_id]} type="select" label="Owning SOC" prompt="Select SOC" options={Enum.map(@socs, &{&1.name, &1.id})} required />
        </div>

        <div class="flex justify-end space-x-3">
          <.button type="submit" variant="primary">Create Company</.button>
        </div>
      </.form>
    </div>
    """
  end
end
