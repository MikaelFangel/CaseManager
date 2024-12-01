defmodule CaseManagerWeb.UsersLive.Index do
  @moduledoc false
  use CaseManagerWeb, :live_view

  alias AshPhoenix.Form
  alias CaseManager.Teams.User
  alias CaseManagerWeb.Helpers

  @impl true
  def mount(_params, _session, socket) do
    page = User.page_by_name_asc!(load: [:full_name, :team])
    users = page.results

    socket =
      socket
      |> assign(:menu_item, :users)
      |> assign(:logo_img, Helpers.load_logo())
      |> assign(current_user: socket.assigns.current_user)
      |> assign(:users, users)
      |> assign(:page, page)
      |> assign(:more_pages?, page.more?)
      |> assign(:show_form_modal, false)
      |> assign(:pending_refresh?, false)

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
      |> assign(:more_pages?, page.more?)

    {:noreply, socket}
  end

  @impl true
  def handle_event("refresh_users", _params, socket) do
    page = User.page_by_name_asc!(load: [:full_name, :team])
    users = page.results

    socket =
      socket
      |> assign(:users, users)
      |> assign(:page, page)
      |> assign(:more_pages?, page.more?)
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

  @impl true
  def handle_event("show_form_modal", %{"user_id" => user_id}, socket) do
    user = Ash.get!(User, user_id)

    user
    |> Form.for_update(:update_user, forms: [auto?: true])
    |> set_form_for_modal(socket)
  end

  @impl true
  def handle_event("show_form_modal", _params, socket) do
    User
    |> Form.for_create(:register_with_password, forms: [auto?: true])
    |> set_form_for_modal(socket)
  end

  @impl true
  def handle_event("hide_form_modal", _params, socket) do
    socket = assign(socket, :show_form_modal, false)

    {:noreply, socket}
  end

  defp set_form_for_modal(form, socket) do
    form = to_form(form)

    socket =
      socket
      |> assign(:form, form)
      |> assign(:cta, gettext("Create User"))
      |> assign(:show_form_modal, true)

    {:noreply, socket}
  end
end
