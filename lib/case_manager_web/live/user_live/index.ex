defmodule CaseManagerWeb.UserLive.Index do
  @moduledoc false
  use CaseManagerWeb, :live_view

  alias AshPhoenix.Form
  alias CaseManager.Teams
  alias CaseManagerWeb.Helpers

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:menu_item, :user)
      |> assign(:logo_img, Helpers.load_logo())

    {:ok, socket}
  end

  @impl true
  def handle_params(_params, _url, socket) do
    info_form =
      socket.assigns[:current_user]
      |> Teams.form_to_edit_user()
      |> to_form()

    password_form =
      socket.assigns[:current_user]
      |> Teams.form_to_edit_user()
      |> to_form()

    socket =
      socket
      |> assign(:info_form, info_form)
      |> assign(:password_form, password_form)

    {:noreply, socket}
  end

  @impl true
  def handle_event("validate_info", %{"form" => params}, socket) do
    form = Form.validate(socket.assigns.info_form, params)
    {:noreply, assign(socket, info_form: form)}
  end

  @impl true
  def handle_event("validate_password", %{"form" => params}, socket) do
    form = Form.validate(socket.assigns.password_form, params)
    {:noreply, assign(socket, password_form: form)}
  end

  @impl true
  def handle_event("update_info", %{"form" => params}, socket) do
    case Form.submit(socket.assigns.info_form, params: params) do
      {:ok, _user} ->
        {:noreply, put_flash(socket, :info, gettext("Changes saved."))}

      {:error, form} ->
        {:noreply,
         socket
         |> assign(:info_form, form)
         |> push_patch(to: ~p"/user")
         |> put_flash(:error, gettext("User save error."))}
    end
  end

  @impl true
  def handle_event("update_password", %{"form" => params}, socket) do
    case Form.submit(socket.assigns.password_form, params: params) do
      {:ok, _user} ->
        {:noreply,
         socket
         |> push_patch(to: ~p"/user")
         |> put_flash(:info, gettext("Changes saved."))}

      {:error, form} ->
        {:noreply, socket |> assign(:password_form, form) |> put_flash(:error, gettext("Password update failed."))}
    end
  end
end
