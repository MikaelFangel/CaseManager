defmodule CaseManagerWeb.CompanyLive.Index do
  @moduledoc false
  use CaseManagerWeb, :live_view

  alias CaseManager.Organizations

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:selected_companies, [])
      |> assign(:company_shared_with, [])
      |> assign(:drawer_open, false)
      |> assign(:drawer_minimized, false)
      |> assign(:selected_company, nil)
      |> assign(:active_tab, :all)
      |> assign(:user_socs, [])

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
            <.shared_with_card companies={@company_shared_with} />
          </div>
        <% else %>
          <div class="flex h-full items-center justify-center text-base-content/70">
            <p>Select a company to view details</p>
          </div>
        <% end %>
        <.drawer title="Share Customers" open={@drawer_open} minimized={@drawer_minimized} user_socs={@user_socs} selected_companies={@selected_companies}></.drawer>
      </:right>
    </Layouts.split>
    """
  end

  @impl true
  def handle_event("set_tab", %{"tab" => tab}, socket) do
    {:noreply, push_patch(socket, to: ~p"/company?tab=#{tab}")}
  end

  defp error_to_string(changeset) do
    changeset
    |> Ecto.Changeset.traverse_errors(fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
    |> Enum.map_join("; ", fn {k, v} -> "#{k}: #{Enum.join(v, ", ")}" end)
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
  def handle_event("open_drawer", _params, socket) do
    user = Ash.load!(socket.assigns.current_user, :socs)

    socket =
      socket
      |> assign(:drawer_open, true)
      |> assign(:drawer_minimized, false)
      |> assign(:user_socs, user.socs)

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
  def handle_event("share_companies", %{"share_form" => form_data}, socket) do
    case Organizations.share_companies_with_soc(
           Ash.get!(CaseManager.Organizations.SOC, form_data["soc_id"]),
           Enum.map(socket.assigns.selected_companies, &String.replace_prefix(&1, "companies-", ""))
         ) do
      {:ok, _result} ->
        socket =
          socket
          |> put_flash(:info, "Companies successfully shared with SOC")
          |> assign(:drawer_open, false)
          |> assign(:selected_companies, [])

        {:noreply, socket}

      {:error, changeset} ->
        socket = put_flash(socket, :error, "Error sharing companies: #{error_to_string(changeset)}")

        {:noreply, socket}
    end
  end

  @impl true
  def handle_event("show_company", %{"id" => id}, socket) do
    company = Organizations.get_company!(id, load: [:soc_accesses])
    user = Ash.load!(socket.assigns.current_user, :socs)

    shared_with =
      Enum.reject(company.soc_accesses, fn soc -> soc.id in user.socs end)

    socket =
      socket
      |> assign(:selected_company, company)
      |> assign(:company_shared_with, shared_with)

    {:noreply, socket}
  end

  defp get_companies_for_tab(:all, user) do
    get_companies_for_tab(:managed, user) ++ get_companies_for_tab(:shared, user)
  end

  defp get_companies_for_tab(:managed, user) do
    user = Ash.load!(user, :socs)

    user.socs
    |> Enum.flat_map(fn soc -> Organizations.get_managed_companies!(soc.id) end)
    |> Enum.uniq_by(fn company -> company.id end)
  end

  defp get_companies_for_tab(:shared, user) do
    user = Ash.load!(user, socs: [:company_accesses])

    user.socs
    |> Enum.flat_map(fn soc -> soc.company_accesses end)
    |> Enum.uniq_by(fn company -> company.id end)
  end

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

  attr :title, :string
  attr :minimized, :boolean, default: false
  attr :open, :boolean, default: false
  attr :user_socs, :list, default: []
  attr :selected_companies, :list, default: []
  slot :inner_block

  defp drawer(assigns) do
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
              <.share_form_for_drawer socs={@user_socs} selected_companies={@selected_companies} />
            <% end %>
          </div>
        </div>
      </div>
    <% end %>
    """
  end

  attr :socs, :list, required: true
  attr :selected_companies, :list, required: true

  defp share_form_for_drawer(assigns) do
    ~H"""
    <div class="space-y-6">
      <.form for={%{}} as={:share_form} phx-submit="share_companies">
        <div class="mb-4">
          <p class="text-base-content/70 mb-2">Selected companies: {length(@selected_companies)}</p>
        </div>

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
end
