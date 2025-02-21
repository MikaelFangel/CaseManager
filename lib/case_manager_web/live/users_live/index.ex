defmodule CaseManagerWeb.UsersLive.Index do
  @moduledoc false
  use CaseManagerWeb, :live_view

  alias AshPhoenix.Form
  alias CaseManager.Teams
  alias CaseManager.Teams.User
  alias CaseManagerWeb.Helpers

  @impl true
  def mount(_params, _session, socket) do
    current_user = socket.assigns.current_user
    users = Teams.list_users!(actor: current_user)

    socket =
      socket
      |> assign(:menu_item, :users)
      |> assign(:logo_img, Helpers.load_logo())
      |> assign(current_user: current_user)
      |> assign(:users, users.results)
      |> assign(:page, users)
      |> assign(:more_users?, users.more?)
      |> assign(:show_form_modal, false)
      |> assign(:pending_refresh?, false)
      |> assign(:user_id, nil)

    {:ok, socket}
  end

  @impl true
  def handle_info({:saved_user, _params}, socket) do
    socket =
      socket
      |> assign(:show_form_modal, false)
      |> assign(:pending_refresh?, true)

    {:noreply, socket}
  end

  @impl true
  # This is needed if sending flash messages from the form live component
  def handle_info({:set_flash, type, message}, socket) do
    socket = put_flash(socket, type, message)

    {:noreply, socket}
  end

  @impl true
  def handle_params(_params, _url, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("load_more_users", _params, socket) do
    page = Ash.page!(socket.assigns.page, :next)
    users = socket.assigns.users ++ page.results

    socket =
      socket
      |> assign(:users, users)
      |> assign(:page, page)
      |> assign(:more_users?, page.more?)

    {:noreply, socket}
  end

  @impl true
  def handle_event("refresh_users", _params, socket) do
    users = Teams.list_users!(actor: socket.assigns.current_user)

    socket =
      socket
      |> assign(:users, users.results)
      |> assign(:page, users)
      |> assign(:more_users?, users.more?)
      |> assign(:pending_refresh?, false)

    {:noreply, socket}
  end

  @impl true
  def handle_event("delete_user", %{"user_id" => user_id}, socket) do
    socket =
      case Teams.get_user_by_id(user_id, actor: socket.assigns.current_user) do
        {:ok, user} ->
          Ash.destroy!(user)
          assign(socket, :pending_refresh?, true)

        {:error, _error} ->
          put_flash(socket, :error, gettext("User already deleted"))
      end

    {:noreply, socket}
  end

  @impl true
  def handle_event("show_form_modal", %{"user_id" => user_id}, socket) do
    socket = assign(socket, :cta, gettext("Edit User"))

    user_id
    |> Teams.get_user_by_id!(actor: socket.assigns.current_user)
    |> Form.for_update(:update, forms: [auto?: true], actor: socket.assigns[:current_user])
    |> set_form_for_modal(socket)
  end

  @impl true
  def handle_event("show_form_modal", _params, socket) do
    socket = assign(socket, :cta, gettext("Create User"))

    User
    |> Form.for_create(:register_with_password, forms: [auto?: true], actor: socket.assigns[:current_user])
    |> set_form_for_modal(socket)
  end

  @impl true
  def handle_event("hide_form_modal", _params, socket) do
    socket = assign(socket, :show_form_modal, false)

    {:noreply, socket}
  end

  @impl true
  def handle_event("show_confirmation_modal", %{"user_id" => user_id}, socket) do
    socket = assign(socket, :user_id, user_id)

    {:noreply, socket}
  end

  @impl true
  def handle_event("hide_confirmation_modal", _params, socket) do
    socket = assign(socket, :user_id, nil)

    {:noreply, socket}
  end

  defp set_form_for_modal(form, socket) do
    form = to_form(form)

    socket =
      socket
      |> assign(:form, form)
      |> assign(:show_form_modal, true)

    {:noreply, socket}
  end
end
