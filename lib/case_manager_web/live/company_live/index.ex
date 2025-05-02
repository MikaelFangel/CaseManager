defmodule CaseManagerWeb.CompanyLive.Index do
  @moduledoc false
  use CaseManagerWeb, :live_view

  alias CaseManager.Organizations

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:selected_companies, [])
      |> assign(:selected_company, nil)
      |> assign(:active_tab, :all)

    {:ok, socket}
  end

  @impl true
  def handle_params(params, _uri, socket) do
    tab = params |> Map.get("tab", "all") |> String.to_existing_atom()

    socket =
      socket
      |> assign(:active_tab, tab)
      |> stream(:companies, get_companies_for_tab(tab, socket.assigns.current_user), reset: true)

    {:noreply, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.split flash={@flash} search_placeholder="Search companies">
      <:top>
        <.header class="h-12">
          <:actions>
            <.button :if={length(@selected_companies) > 0} variant="primary" phx-click="open_drawer">
              Share {length(@selected_companies)} companies
            </.button>
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

          <div class="mt-auto pt-4 pb-2 flex justify-center">
            <div role="tablist" class="tabs tabs-box">
              <a role="tab" class={"tab #{if @active_tab == :all, do: "tab-active"}"} phx-click="set_tab" phx-value-tab="all">All</a>
              <a role="tab" class={"tab #{if @active_tab == :managed, do: "tab-active"}"} phx-click="set_tab" phx-value-tab="managed">Managed</a>
              <a role="tab" class={"tab #{if @active_tab == :shared, do: "tab-active"}"} phx-click="set_tab" phx-value-tab="shared">Shared with You</a>
            </div>
          </div>
        </div>
      </:left>
      <:right>
        <%= if @selected_company do %>
          <div class="py-4 px-2">
            <h2 class="text-xl font-bold mb-4">{@selected_company.name}</h2>
            <!-- Company details content here -->
          </div>
        <% else %>
          <div class="flex h-full items-center justify-center text-base-content/70">
            <p>Select a company to view details</p>
          </div>
        <% end %>
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

      {:noreply, assign(socket, :selected_companies, updated_selected)}
    else
      {:noreply, socket}
    end
  end

  @impl true
  def handle_event("show_company", %{"id" => id}, socket) do
    company = Organizations.get_company!(id)
    {:noreply, assign(socket, :selected_company, company)}
  end

  defp get_companies_for_tab(:all, _user) do
    Organizations.list_company!()
  end

  defp get_companies_for_tab(:managed, _user) do
    Organizations.list_company!()
  end

  defp get_companies_for_tab(:shared, user) do
    user = Ash.load!(user, socs: [:company_accesses])

    user.socs
    |> Enum.flat_map(fn soc -> soc.company_accesses end)
    |> Enum.uniq_by(fn company -> company.id end)
  end
end
