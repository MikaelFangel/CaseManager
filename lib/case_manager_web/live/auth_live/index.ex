defmodule CaseManagerWeb.AuthLive.Index do
  use CaseManagerWeb, :live_view

  alias AshPhoenix.Form
  alias CaseManager.Teams.User

  @impl true
  def mount(_params, _session, socket) do
    layout =
      if(socket.assigns.live_action == :onboarding,
        do: {CaseManagerWeb.Layouts, :onboarding},
        else: false
      )

    {:ok, socket, layout: layout}
  end

  @impl true
  def handle_params(params, _uri, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :register, _params) do
    socket
    |> assign(:form_id, "sign-up-form")
    |> assign(:cta, "Sign up")
    |> assign(:action, ~p"/auth/user/password/register")
    |> assign(
      :form,
      Form.for_create(User, :register_with_password, api: CaseManager.Teams, as: "user")
    )
  end

  defp apply_action(socket, :onboarding, _params) do
    socket
    |> assign(:form_id, "onboarding-form")
    |> assign(:cta, "Create your first MSSP admin")
    |> assign(:action, ~p"/auth/user/password/register")
    |> assign(
      :form,
      Form.for_create(User, :register_with_password, api: CaseManager.Teams, as: "user")
    )
  end

  defp apply_action(socket, :sign_in, _params) do
    socket
    |> assign(:form_id, "sign-in-form")
    |> assign(:cta, "Sign in")
    |> assign(:action, ~p"/auth/user/password/sign_in")
    |> assign(
      :form,
      Form.for_action(User, :sign_in_with_password, api: CaseManager.Teams, as: "user")
    )
  end
end
