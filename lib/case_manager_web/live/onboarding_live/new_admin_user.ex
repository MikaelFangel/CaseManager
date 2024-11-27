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
  def handle_params(params, _uri, socket) do
    socket =
      socket
      |> assign(:form_id, "onboarding-form")
      |> assign(:cta, "Create your first MSSP admin")
      |> assign(:action, ~p"/auth/user/password/register")
      |> assign(
        :form,
        Form.for_create(User, :register_with_password, api: CaseManager.Teams, as: "user")
      )
    
    {:noreply, socket}
  end
end

