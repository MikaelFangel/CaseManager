defmodule CaseManagerWeb.AuthLive.Index do
  @moduledoc false
  use CaseManagerWeb, :live_view

  alias AshPhoenix.Form
  alias CaseManager.Teams.User

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket, layout: false}
  end

  @impl true
  def handle_params(_params, _uri, socket) do
    socket =
      socket
      |> assign(:form_id, "sign-in-form")
      |> assign(:cta, gettext("Sign in"))
      |> assign(:action, ~p"/auth/user/password/sign_in")
      |> assign(
        :form,
        Form.for_action(User, :sign_in_with_password, api: CaseManager.Teams, as: "user")
      )

    {:noreply, socket}
  end
end
