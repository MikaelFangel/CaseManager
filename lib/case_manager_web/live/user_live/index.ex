defmodule CaseManagerWeb.UserLive.Index do
  @moduledoc false
  use CaseManagerWeb, :live_view

  alias CaseManager.Accounts

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} search_placeholder="Search users">
      <.header>
        <:actions>
          <.button variant="primary" navigate={~p"/user/new"}>
            <.icon name="hero-plus" /> New User
          </.button>
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
          <.link navigate={~p"/user/#{user}/edit"}>Edit</.link>
        </:action>
        <:action :let={{id, user}}>
          <.link phx-click={JS.push("delete", value: %{id: user.id}) |> hide("##{id}")} data-confirm="Are you sure?">
            Delete
          </.link>
        </:action>
      </.table>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Listing Users")
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
  def handle_event("delete", %{"id" => id}, socket) do
    user = Accounts.get_user!(id)
    {:ok, _} = Accounts.delete_user(user)

    {:noreply, stream_delete(socket, :users, user)}
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
