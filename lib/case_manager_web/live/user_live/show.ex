defmodule CaseManagerWeb.UserLive.Show do
  @moduledoc false
  use CaseManagerWeb, :live_view

  alias CaseManager.Accounts

  require Ash.Query

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
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
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    user = Accounts.get_user!(id)
    api_keys = load_user_api_keys(user.id)

    {:ok,
     socket
     |> assign(:page_title, "Show User")
     |> assign(:user, user)
     |> assign(:api_keys, api_keys)
     |> assign(:new_api_key, nil)}
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

      {:error, _error} ->
        {:noreply, put_flash(socket, :error, "Failed to delete API key")}
    end
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
