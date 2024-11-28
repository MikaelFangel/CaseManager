defmodule CaseManagerWeb.UsersLive.Index do
  @moduledoc false
  use CaseManagerWeb, :live_view

  alias CaseManagerWeb.Helpers
  alias CaseManager.Teams.User

  @impl true
  def mount(_params, _session, socket) do
    users = Ash.read!(User, load: [:full_name, :team])

    socket =
      socket
      |> assign(:menu_item, :users)
      |> assign(:logo_img, Helpers.load_logo())
      |> assign(:users, users)
      |> assign(:pending_refresh?, false)

    {:ok, socket}
  end

  @impl true
  def handle_params(_params, _url, socket) do

    {:noreply, socket}
  end

  @impl true
  def handle_event("refresh_users", _params, socket) do
    users = Ash.read!(User, load: [:full_name, :team])

    socket =
      socket
      |> assign(:users, users)
      |> assign(:pending_refresh?, false)

    {:noreply, socket}
  end

  @impl true
  def handle_event("delete_user", %{"user_id" => user_id}, socket) do
    socket =
      case Ash.get(User, user_id) do
        {:ok, user} ->
          Ash.destroy!(user)
          assign(socket, :pending_refresh?, true)

        {:error, _} ->
          put_flash(socket, :error, gettext("User already deleted"))
      end

    {:noreply, socket}
  end
end
