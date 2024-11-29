defmodule CaseManagerWeb.OnboardingLive.NewAdminUser do
  @moduledoc false
  use CaseManagerWeb, :live_view

  alias AshPhoenix.Form
  alias CaseManager.Teams.User

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket, layout: {CaseManagerWeb.Layouts, :onboarding}}
  end

  @impl true
  def handle_info({:saved_user, params}, socket) do
    socket = push_navigate(socket, to: ~p"/")

    {:noreply, socket}
  end

  @impl true
  # This is needed if sending flash messages from the form live component
  def handle_info({:set_flash, type, message}, socket) do
    socket = put_flash(socket, type, message)

    {:noreply, socket}
  end

  @impl true
  def handle_params(params, _uri, socket) do
    # as: "user" is needed to use ash authentication to login after creating a user
    form =
      User
      |> Form.for_create(:register_with_password, forms: [auto?: true], as: "user")
      |> to_form()

    socket =
      socket
      |> assign(:form, form)
      |> assign(:cta, gettext("Create your first MSSP admin"))

    {:noreply, socket}
  end
end
