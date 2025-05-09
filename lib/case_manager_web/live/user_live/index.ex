defmodule CaseManagerWeb.UserLive.Index do
  @moduledoc false
  use CaseManagerWeb, :live_view

  alias AshPhoenix.Form
  alias CaseManager.Accounts

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} search_placeholder="Search users">
      <.header>
        <:actions>
          <button class="btn btn-primary" onclick="user_modal.showModal()">
            <.icon name="hero-plus" /> New User
          </button>
        </:actions>
      </.header>

      <.table id="users" rows={@streams.users} row_click={fn {_id, user} -> JS.navigate(~p"/user/#{user}") end}>
        <:col :let={{_id, user}} label="Email">{user.email}</:col>
        <:col :let={{_id, user}} label="Name">{user.full_name}</:col>
        <:col :let={{_id, user}} label="SOC">{user.socs |> Enum.map(& &1.name) |> Enum.join(", ")}</:col>
        <:col :let={{_id, user}} label="Company">{user.companies |> Enum.map(& &1.name) |> Enum.join(", ")}</:col>
        <:action :let={{_id, user}}>
          <div class="sr-only">
            <.link navigate={~p"/user/#{user}"}>Show</.link>
          </div>
          <.link navigate={~p"/user/#{user}"}>Edit</.link>
        </:action>
        <:action :let={{id, user}}>
          <.link phx-click={JS.push("delete", value: %{id: user.id}) |> hide("##{id}")} data-confirm="Are you sure?">
            Delete
          </.link>
        </:action>
      </.table>

      <dialog id="user_modal" class="modal">
        <div class="modal-box">
          <h3 class="font-bold text-lg mb-4">Create New User</h3>
          <.form for={@user_form} phx-submit="save_user" class="space-y-4">
            <.input field={@user_form[:email]} type="email" label="Email" />
            <.input field={@user_form[:first_name]} type="text" label="First name" />
            <.input field={@user_form[:last_name]} type="text" label="Last name" />
            <.input field={@user_form[:password]} type="password" label="Password" />
            <.input field={@user_form[:password_confirmation]} type="password" label="Password confirmation" />

            <div class="space-y-2">
              <label class="block text-sm font-medium">SOCs</label>
              <div class="space-y-1">
                <%= for soc <- @socs do %>
                  <div class="flex items-center">
                    <input type="checkbox" id={"soc-#{soc.id}"} name="form[socs][]" value={soc.id} class="checkbox checkbox-sm mr-2" />
                    <label for={"soc-#{soc.id}"}>{soc.name}</label>
                  </div>
                <% end %>
              </div>
            </div>

            <div class="space-y-2">
              <label class="block text-sm font-medium">Companies</label>
              <div class="space-y-1">
                <%= for company <- @companies do %>
                  <div class="flex items-center">
                    <input type="checkbox" id={"company-#{company.id}"} name="form[companies][]" value={company.id} class="checkbox checkbox-sm mr-2" />
                    <label for={"company-#{company.id}"}>{company.name}</label>
                  </div>
                <% end %>
              </div>
            </div>

            <div class="modal-action">
              <button type="button" class="btn" onclick="user_modal.close()">Cancel</button>
              <button type="submit" class="btn btn-primary">Create User</button>
            </div>
          </.form>
        </div>
      </dialog>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    companies = CaseManager.Organizations.list_company!()
    socs = CaseManager.Organizations.list_soc!()

    user_form = to_form(CaseManager.Accounts.form_to_create_user())

    {:ok,
     socket
     |> assign(:page_title, "Listing Users")
     |> assign(:user_form, user_form)
     |> assign(:companies, companies)
     |> assign(:socs, socs)
     |> stream(:users, Accounts.list_user!(load: [:companies, :socs, :full_name]))}
  end

  @impl true
  def handle_params(params, _uri, socket) do
    query = Map.get(params, "q", "")
    users = CaseManager.Accounts.search_users!(query, load: [:companies, :socs, :full_name])

    socket = stream(socket, :users, users, reset: true)
    {:noreply, socket}
  end

  @impl true
  def handle_event("search", %{"query" => search}, socket) do
    params = update_params(socket, %{q: search})
    {:noreply, push_patch(socket, to: ~p"/user/?#{params}")}
  end

  @impl true
  def handle_event("add_form", %{"path" => path} = _params, socket) do
    form = AshPhoenix.Form.add_form(socket.assigns.user_form, path, type: :create)
    {:noreply, assign(socket, user_form: form)}
  end

  @impl true
  def handle_event("remove_form", %{"path" => path} = _params, socket) do
    form = AshPhoenix.Form.remove_form(socket.assigns.user_form, path)
    {:noreply, assign(socket, user_form: form)}
  end

  @impl true
  def handle_event("validate", %{"form" => params}, socket) do
    form = Form.validate(socket.assigns.user_form, params)
    {:noreply, assign(socket, user_form: form)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    user = Accounts.get_user!(id)
    {:ok, _} = Accounts.delete_user(user)

    {:noreply, stream_delete(socket, :users, user)}
  end

  @impl true
  def handle_event("save_user", %{"form" => user_params}, socket) do
    # Get SOCs and companies from form
    socs = Map.get(user_params, "socs", [])
    companies = Map.get(user_params, "companies", [])

    # Ensure we're working with proper lists
    socs = if is_list(socs), do: socs, else: [socs]
    companies = if is_list(companies), do: companies, else: [companies]

    # Filter out any empty values
    socs = Enum.filter(socs, &(&1 != nil && &1 != ""))
    companies = Enum.filter(companies, &(&1 != nil && &1 != ""))

    # Prepare params for submission
    submission_params = %{
      "email" => user_params["email"],
      "password" => user_params["password"],
      "password_confirmation" => user_params["password_confirmation"],
      "first_name" => user_params["first_name"],
      "last_name" => user_params["last_name"],
      "socs" => socs,
      "companies" => companies
    }

    case AshPhoenix.Form.submit(socket.assigns.user_form, params: submission_params) do
      {:ok, user} ->
        # Get the user with relationships loaded
        loaded_user = Accounts.get_user!(user.id, load: [:companies, :socs, :full_name])

        socket =
          socket
          |> put_flash(:info, "User created successfully")
          |> assign(user_form: to_form(CaseManager.Accounts.form_to_create_user()))
          |> stream_insert(:users, loaded_user)

        {:noreply, socket}

      {:error, form} ->
        {:noreply, assign(socket, user_form: form)}
    end
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
end
