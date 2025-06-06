defmodule CaseManagerWeb.UserLive.Show do
  @moduledoc false
  use CaseManagerWeb, :live_view

  alias CaseManager.Accounts

  require Ash.Query

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} user_roles={@user_roles}>
      <.header>
        {@user.first_name} {@user.last_name}
        <:actions>
          <.button navigate={~p"/user"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button variant="primary" navigate={~p"/user/#{@user}"}>
            <.icon name="hero-pencil-square" /> Edit user
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="Database ID">{@user.id}</:item>
        <:item title="Email">{@user.email}</:item>
      </.list>

      <div class="mt-8">
        <.header>
          Company Memberships
          <:subtitle>Organizations this user belongs to as a company member.</:subtitle>
          <:actions>
            <button class="btn btn-primary" onclick="company_modal.showModal()">
              <.icon name="hero-plus" /> Add Company
            </button>
          </:actions>
        </.header>

        <%= if Enum.empty?(@company_users) do %>
          <div class="hero min-h-32">
            <div class="hero-content text-center">
              <div class="max-w-md">
                <.icon name="hero-building-office" class="mx-auto h-12 w-12 text-base-content/40" />
                <h3 class="mt-2 text-lg font-bold">No company memberships</h3>
                <p class="mt-1 text-sm opacity-60">This user is not a member of any companies.</p>
              </div>
            </div>
          </div>
        <% else %>
          <.table id="companies" rows={@company_users}>
            <:col :let={company_user} label="Company Name">
              {company_user.company.name}
            </:col>
            <:col :let={company_user} label="Role">
              <.badge type={:info}>{company_user.user_role}</.badge>
            </:col>
            <:action :let={company_user}>
              <div class="flex gap-2">
                <button phx-click="edit_company_membership" phx-value-company-id={company_user.company.id} class="btn btn-sm btn-primary btn-outline">
                  Edit
                </button>
                <button phx-click="remove_company_membership" phx-value-company-id={company_user.company.id} data-confirm="Are you sure you want to remove this company membership?" class="btn btn-sm btn-error btn-outline">
                  Remove
                </button>
              </div>
            </:action>
          </.table>
        <% end %>
      </div>

      <div class="mt-8">
        <.header>
          SOC Memberships
          <:subtitle>Security Operations Centers this user belongs to.</:subtitle>
          <:actions>
            <button class="btn btn-primary" onclick="soc_modal.showModal()">
              <.icon name="hero-plus" /> Add SOC
            </button>
          </:actions>
        </.header>

        <%= if Enum.empty?(@soc_users) do %>
          <div class="hero min-h-32">
            <div class="hero-content text-center">
              <div class="max-w-md">
                <.icon name="hero-shield-check" class="mx-auto h-12 w-12 text-base-content/40" />
                <h3 class="mt-2 text-lg font-bold">No SOC memberships</h3>
                <p class="mt-1 text-sm opacity-60">This user is not a member of any SOCs.</p>
              </div>
            </div>
          </div>
        <% else %>
          <.table id="socs" rows={@soc_users}>
            <:col :let={soc_user} label="SOC Name">
              {soc_user.soc.name}
            </:col>
            <:col :let={soc_user} label="Role">
              <.badge type={:info}>{soc_user.user_role}</.badge>
            </:col>
            <:action :let={soc_user}>
              <div class="flex gap-2">
                <button phx-click="edit_soc_membership" phx-value-soc-id={soc_user.soc.id} class="btn btn-sm btn-primary btn-outline">
                  Edit
                </button>
                <button phx-click="remove_soc_membership" phx-value-soc-id={soc_user.soc.id} data-confirm="Are you sure you want to remove this SOC membership?" class="btn btn-sm btn-error btn-outline">
                  Remove
                </button>
              </div>
            </:action>
          </.table>
        <% end %>
      </div>

      <div class="mt-8">
        <.header>
          API Keys
          <:subtitle>Manage API keys for this user. Keys expire after 1 year.</:subtitle>
          <:actions>
            <.button phx-click="generate_api_key" variant="primary">
              <.icon name="hero-plus" /> Generate New API Key
            </.button>
          </:actions>
        </.header>

        <%= if @new_api_key do %>
          <div class="alert alert-success mt-4">
            <.icon name="hero-key" class="shrink-0 h-6 w-6" />
            <div class="flex-1">
              <h4 class="font-bold">New API Key Generated</h4>
              <p class="text-sm">Copy this key now - you won't be able to see it again!</p>
              <div class="mt-2 flex gap-2">
                <div class="flex-1 p-2 bg-base-100 border rounded font-mono text-sm break-all" id="api-key-text">
                  {@new_api_key}
                </div>
                <button class="btn btn-sm btn-outline" phx-hook="CopyToClipboard" id="copy-api-key" data-target="api-key-text" title="Copy to clipboard">
                  <.icon name="hero-clipboard-document" class="h-4 w-4" />
                </button>
              </div>
            </div>
            <button class="btn btn-sm btn-ghost" phx-click="dismiss_api_key" title="Dismiss">
              <.icon name="hero-x-mark" class="h-4 w-4" />
            </button>
          </div>
        <% end %>

        <div class="mt-6">
          <%= if Enum.empty?(@api_keys) do %>
            <div class="hero min-h-32">
              <div class="hero-content text-center">
                <div class="max-w-md">
                  <.icon name="hero-key" class="mx-auto h-12 w-12 text-base-content/40" />
                  <h3 class="mt-2 text-lg font-bold">No API keys</h3>
                  <p class="mt-1 text-sm opacity-60">Get started by generating a new API key.</p>
                </div>
              </div>
            </div>
          <% else %>
            <.table id="api-keys" rows={@api_keys}>
              <:col :let={api_key} label="Created" class="text-sm">
                {Calendar.strftime(api_key.inserted_at, "%Y-%m-%d %H:%M")}
              </:col>
              <:col :let={api_key} label="Expires" class="text-sm">
                {Calendar.strftime(api_key.expires_at, "%Y-%m-%d %H:%M")}
              </:col>
              <:col :let={api_key} label="Status">
                <%= if api_key.valid do %>
                  <.badge type={:success}>Valid</.badge>
                <% else %>
                  <.badge type={:error}>Expired</.badge>
                <% end %>
              </:col>
              <:col label="Key Preview" class="font-mono text-sm opacity-60">
                casemanager_•••••••••••••••••
              </:col>
              <:action :let={api_key}>
                <button phx-click="delete_api_key" phx-value-id={api_key.id} data-confirm="Are you sure you want to delete this API key? This action cannot be undone." class="btn btn-sm btn-error btn-outline">
                  Delete
                </button>
              </:action>
            </.table>
          <% end %>
        </div>
      </div>

      <dialog id="company_modal" class="modal">
        <div class="modal-box">
          <h3 class="font-bold text-lg">Add Company Membership</h3>
          <p class="py-4">Select a company and role for {@user.first_name} {@user.last_name}</p>

          <form id="add-company-form" phx-submit="create_company_membership">
            <.input type="select" name="company_id" label="Company" value="" prompt="Select a company..." options={Enum.map(@available_companies, &{&1.name, &1.id})} required />

            <.input
              type="select"
              name="user_role"
              label="Role"
              value=""
              prompt="Select a role..."
              options={[
                {"Admin", "admin"},
                {"Analyst", "analyst"}
              ]}
              required
            />

            <div class="modal-action">
              <button type="submit" class="btn btn-primary">Add Membership</button>
              <button type="button" class="btn" onclick="company_modal.close()">Cancel</button>
            </div>
          </form>
        </div>
      </dialog>

      <dialog id="soc_modal" class="modal">
        <div class="modal-box">
          <h3 class="font-bold text-lg">Add SOC Membership</h3>
          <p class="py-4">Select a SOC and role for {@user.first_name} {@user.last_name}</p>

          <form id="add-soc-form" phx-submit="create_soc_membership">
            <.input type="select" name="soc_id" label="SOC" value="" prompt="Select a SOC..." options={Enum.map(@available_socs, &{&1.name, &1.id})} required />

            <.input
              type="select"
              name="user_role"
              label="Role"
              value=""
              prompt="Select a role..."
              options={[
                {"Super Admin", "super_admin"},
                {"Admin", "admin"},
                {"Analyst", "analyst"}
              ]}
              required
            />

            <div class="modal-action">
              <button type="submit" class="btn btn-primary">Add Membership</button>
              <button type="button" class="btn" onclick="soc_modal.close()">Cancel</button>
            </div>
          </form>
        </div>
      </dialog>

      <dialog id="edit_company_modal" class="modal">
        <div class="modal-box">
          <h3 class="font-bold text-lg">Edit Company Membership</h3>
          <%= if @edit_company_membership do %>
            <p class="py-4">Edit role for {@user.first_name} {@user.last_name} at {@edit_company_membership.company.name}</p>

            <form id="edit-company-form" phx-submit="update_company_membership">
              <input type="hidden" name="company_id" value={@edit_company_membership.company.id} />

              <.input
                type="select"
                name="user_role"
                label="Role"
                value={@edit_company_membership.role}
                options={[
                  {"Admin", "admin"},
                  {"Analyst", "analyst"}
                ]}
                required
              />

              <div class="modal-action">
                <button type="submit" class="btn btn-primary">Update Membership</button>
                <button type="button" class="btn" onclick="edit_company_modal.close()" phx-click="close_edit_company_modal">Cancel</button>
              </div>
            </form>
          <% end %>
        </div>
      </dialog>

      <dialog id="edit_soc_modal" class="modal">
        <div class="modal-box">
          <h3 class="font-bold text-lg">Edit SOC Membership</h3>
          <%= if @edit_soc_membership do %>
            <p class="py-4">Edit role for {@user.first_name} {@user.last_name} at {@edit_soc_membership.soc.name}</p>

            <form id="edit-soc-form" phx-submit="update_soc_membership">
              <input type="hidden" name="soc_id" value={@edit_soc_membership.soc.id} />

              <.input
                type="select"
                name="user_role"
                label="Role"
                value={@edit_soc_membership.role}
                options={[
                  {"Super Admin", "super_admin"},
                  {"Admin", "admin"},
                  {"Analyst", "analyst"}
                ]}
                required
              />

              <div class="modal-action">
                <button type="submit" class="btn btn-primary">Update Membership</button>
                <button type="button" class="btn" onclick="edit_soc_modal.close()" phx-click="close_edit_soc_modal">Cancel</button>
              </div>
            </form>
          <% end %>
        </div>
      </dialog>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    user = Accounts.get_user!(id)
    current_user = Ash.load!(socket.assigns.current_user, [:soc_roles, :company_roles])
    api_keys = load_user_api_keys(user.id)
    available_companies = CaseManager.Organizations.list_company!()
    available_socs = CaseManager.Organizations.list_soc!()

    # Load join table records directly to ensure correct company/role pairing
    company_users =
      CaseManager.Organizations.list_company_users!(
        query: [
          filter: [user_id: user.id],
          load: [:company]
        ]
      )

    soc_users =
      CaseManager.Organizations.list_soc_users!(
        query: [
          filter: [user_id: user.id],
          load: [:soc]
        ]
      )

    {:ok,
     socket
     |> assign(:page_title, "Show User")
     |> assign(:user, user)
     |> assign(:api_keys, api_keys)
     |> assign(:new_api_key, nil)
     |> assign(:available_companies, available_companies)
     |> assign(:available_socs, available_socs)
     |> assign(:company_users, company_users)
     |> assign(:soc_users, soc_users)
     |> assign(:user_roles, current_user.soc_roles ++ current_user.company_roles)
     |> assign(:edit_company_membership, nil)
     |> assign(:edit_soc_membership, nil)}
  end

  @impl true
  def handle_event("generate_api_key", _params, socket) do
    user = socket.assigns.user
    # 1 year expiration
    expires_at = DateTime.add(DateTime.utc_now(), 365, :day)

    case CaseManager.Accounts.create_api_key(%{
           user_id: user.id,
           expires_at: expires_at
         }) do
      {:ok, api_key} ->
        # Reload API keys list
        api_keys = load_user_api_keys(user.id)
        plaintext_key = api_key.__metadata__.plaintext_api_key

        {:noreply,
         socket
         |> assign(:api_keys, api_keys)
         |> assign(:new_api_key, plaintext_key)
         |> put_flash(:info, "New API key generated successfully. Make sure to copy it now - you won't see it again!")}

      {:error, _error} ->
        {:noreply, put_flash(socket, :error, "Failed to generate API key")}
    end
  end

  @impl true
  def handle_event("api_key_copied", _params, socket) do
    {:noreply, put_flash(socket, :info, "API key copied to clipboard!")}
  end

  @impl true
  def handle_event("dismiss_api_key", _params, socket) do
    {:noreply, assign(socket, :new_api_key, nil)}
  end

  @impl true
  def handle_event("delete_api_key", %{"id" => api_key_id}, socket) do
    case CaseManager.Accounts.delete_api_key(api_key_id) do
      :ok ->
        # Reload API keys list
        api_keys = load_user_api_keys(socket.assigns.user.id)

        {:noreply,
         socket
         |> assign(:api_keys, api_keys)
         |> assign(:new_api_key, nil)
         |> put_flash(:info, "API key deleted successfully")}

      _error ->
        {:noreply, put_flash(socket, :error, "Failed to delete API key")}
    end
  end

  @impl true
  def handle_event("edit_company_membership", %{"company-id" => company_id}, socket) do
    user = socket.assigns.user

    case CaseManager.Organizations.get_company_user(user.id, company_id) do
      {:ok, company_user} ->
        # Load the company relationship if not already loaded
        company_user = Ash.load!(company_user, :company)
        company = company_user.company
        role = company_user.user_role

        {:noreply,
         socket
         |> assign(:edit_company_membership, %{company: company, role: role})
         |> push_event("open-modal", %{id: "edit_company_modal"})}

      {:error, _error} ->
        {:noreply, put_flash(socket, :error, "Company membership not found")}
    end
  end

  @impl true
  def handle_event("remove_company_membership", %{"company-id" => company_id}, socket) do
    user = socket.assigns.user

    case CaseManager.Organizations.get_company_user(user.id, company_id) do
      {:ok, company_user} ->
        case CaseManager.Organizations.delete_company_user(company_user) do
          {:ok, _user} ->
            # Reload join table records
            company_users =
              CaseManager.Organizations.list_company_users!(
                query: [
                  filter: [user_id: user.id],
                  load: [:company]
                ]
              )

            {:noreply,
             socket
             |> assign(:company_users, company_users)
             |> put_flash(:info, "Company membership removed successfully")}

          {:error, _error} ->
            {:noreply, put_flash(socket, :error, "Failed to remove company membership")}
        end

      {:error, _error} ->
        {:noreply, put_flash(socket, :error, "Company membership not found")}
    end
  end

  @impl true
  def handle_event("edit_soc_membership", %{"soc-id" => soc_id}, socket) do
    user = socket.assigns.user

    case CaseManager.Organizations.get_soc_user(user.id, soc_id) do
      {:ok, soc_user} ->
        # Load the soc relationship if not already loaded
        soc_user = Ash.load!(soc_user, :soc)
        soc = soc_user.soc
        role = soc_user.user_role

        {:noreply,
         socket
         |> assign(:edit_soc_membership, %{soc: soc, role: role})
         |> push_event("open-modal", %{id: "edit_soc_modal"})}

      {:error, _error} ->
        {:noreply, put_flash(socket, :error, "SOC membership not found")}
    end
  end

  @impl true
  def handle_event("remove_soc_membership", %{"soc-id" => soc_id}, socket) do
    user = socket.assigns.user

    case CaseManager.Organizations.get_soc_user(user.id, soc_id) do
      {:ok, soc_user} ->
        case CaseManager.Organizations.delete_soc_user(soc_user) do
          {:ok, _user} ->
            # Reload join table records
            soc_users =
              CaseManager.Organizations.list_soc_users!(
                query: [
                  filter: [user_id: user.id],
                  load: [:soc]
                ]
              )

            {:noreply,
             socket
             |> assign(:soc_users, soc_users)
             |> put_flash(:info, "SOC membership removed successfully")}

          {:error, _error} ->
            {:noreply, put_flash(socket, :error, "Failed to remove SOC membership")}
        end

      {:error, _error} ->
        {:noreply, put_flash(socket, :error, "SOC membership not found")}
    end
  end

  @impl true
  def handle_event("create_company_membership", %{"company_id" => company_id, "user_role" => user_role}, socket) do
    user = socket.assigns.user

    case CaseManager.Organizations.create_company_user(%{
           user_id: user.id,
           company_id: company_id,
           user_role: user_role
         }) do
      {:ok, _company_user} ->
        # Reload join table records
        company_users =
          CaseManager.Organizations.list_company_users!(
            query: [
              filter: [user_id: user.id],
              load: [:company]
            ]
          )

        {:noreply,
         socket
         |> assign(:company_users, company_users)
         |> push_event("close-modal", %{id: "company_modal"})
         |> put_flash(:info, "Company membership added successfully")}

      {:error, _error} ->
        {:noreply, put_flash(socket, :error, "Failed to add company membership")}
    end
  end

  @impl true
  def handle_event("create_soc_membership", %{"soc_id" => soc_id, "user_role" => user_role}, socket) do
    user = socket.assigns.user

    case CaseManager.Organizations.create_soc_user(%{
           user_id: user.id,
           soc_id: soc_id,
           user_role: user_role
         }) do
      {:ok, _soc_user} ->
        # Reload join table records
        soc_users =
          CaseManager.Organizations.list_soc_users!(
            query: [
              filter: [user_id: user.id],
              load: [:soc]
            ]
          )

        {:noreply,
         socket
         |> assign(:soc_users, soc_users)
         |> push_event("close-modal", %{id: "soc_modal"})
         |> put_flash(:info, "SOC membership added successfully")}

      {:error, _error} ->
        {:noreply, put_flash(socket, :error, "Failed to add SOC membership")}
    end
  end

  @impl true
  def handle_event("update_company_membership", %{"company_id" => company_id, "user_role" => user_role}, socket) do
    user = socket.assigns.user

    case CaseManager.Organizations.get_company_user(user.id, company_id) do
      {:ok, company_user} ->
        case CaseManager.Organizations.update_company_user(company_user, %{user_role: user_role}) do
          {:ok, _updated_company_user} ->
            # Reload join table records
            company_users =
              CaseManager.Organizations.list_company_users!(
                query: [
                  filter: [user_id: user.id],
                  load: [:company]
                ]
              )

            {:noreply,
             socket
             |> assign(:company_users, company_users)
             |> assign(:edit_company_membership, nil)
             |> push_event("close-modal", %{id: "edit_company_modal"})
             |> put_flash(:info, "Company membership updated successfully")}

          {:error, _error} ->
            {:noreply, put_flash(socket, :error, "Failed to update company membership")}
        end

      {:error, _error} ->
        {:noreply, put_flash(socket, :error, "Company membership not found")}
    end
  end

  @impl true
  def handle_event("update_soc_membership", %{"soc_id" => soc_id, "user_role" => user_role}, socket) do
    user = socket.assigns.user

    case CaseManager.Organizations.get_soc_user(user.id, soc_id) do
      {:ok, soc_user} ->
        case CaseManager.Organizations.update_soc_user(soc_user, %{user_role: user_role}) do
          {:ok, _updated_soc_user} ->
            # Reload join table records
            soc_users =
              CaseManager.Organizations.list_soc_users!(
                query: [
                  filter: [user_id: user.id],
                  load: [:soc]
                ]
              )

            {:noreply,
             socket
             |> assign(:soc_users, soc_users)
             |> assign(:edit_soc_membership, nil)
             |> push_event("close-modal", %{id: "edit_soc_modal"})
             |> put_flash(:info, "SOC membership updated successfully")}

          {:error, _error} ->
            {:noreply, put_flash(socket, :error, "Failed to update SOC membership")}
        end

      {:error, _error} ->
        {:noreply, put_flash(socket, :error, "SOC membership not found")}
    end
  end

  @impl true
  def handle_event("close_edit_company_modal", _params, socket) do
    {:noreply, assign(socket, :edit_company_membership, nil)}
  end

  @impl true
  def handle_event("close_edit_soc_modal", _params, socket) do
    {:noreply, assign(socket, :edit_soc_membership, nil)}
  end

  defp load_user_api_keys(user_id) do
    CaseManager.Accounts.list_api_keys!(
      query: [
        filter: [user_id: user_id],
        load: [:valid],
        sort: [inserted_at: :desc]
      ]
    )
  end
end
