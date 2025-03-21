defmodule CaseManagerWeb.UsersLive.Index do
  @moduledoc false
  use CaseManagerWeb, :live_view

  alias AshPhoenix.Form
  alias CaseManager.Teams
  alias CaseManager.Teams.User
  alias CaseManagerWeb.Helpers

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:menu_item, :users)
      |> assign(:logo_img, Helpers.load_logo())
      |> assign(:show_form_modal, false)
      |> assign(:user_id, nil)

    {:ok, socket}
  end

  @impl true
  def handle_info({:saved_user, _params}, socket) do
    socket = assign(socket, :show_form_modal, false)

    params = remove_empty(%{q: socket.assigns[:search]})
    {:noreply, push_patch(socket, to: ~p"/users/?#{params}")}
  end

  @impl true
  # This is needed if sending flash messages from the form live component
  def handle_info({:set_flash, type, message}, socket) do
    socket = put_flash(socket, type, message)

    {:noreply, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    query_text = Map.get(params, "q", "")

    current_user = socket.assigns.current_user
    users = Teams.search_users!(query_text, actor: current_user)

    socket =
      socket
      |> assign(current_user: current_user)
      |> assign(:users, users.results)
      |> assign(:page, users)
      |> assign(:more_users?, users.more?)
      |> assign(search: query_text)

    {:noreply, socket}
  end

  @impl true
  def handle_event("search", %{"search" => search}, socket) do
    params = remove_empty(%{q: search})
    {:noreply, push_patch(socket, to: ~p"/users/?#{params}")}
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
  def handle_event("delete_user", %{"user_id" => user_id}, socket) do
    params = remove_empty(%{q: socket.assigns[:search]})

    socket =
      case Teams.delete_user_by_id(user_id, actor: socket.assigns.current_user) do
        :ok ->
          socket

        {:error, _error} ->
          put_flash(socket, :error, gettext("User already deleted"))
      end

    {:noreply, push_patch(socket, to: ~p"/users/?#{params}")}
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

  defp remove_empty(params) do
    Enum.filter(params, fn {_key, val} -> val != "" end)
  end
end
