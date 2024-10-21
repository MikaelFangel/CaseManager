defmodule CaseManagerWeb.AuthLive.Index do
  use CaseManagerWeb, :live_view

  alias AshPhoenix.Form
  alias CaseManager.Teams.User

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket, layout: false}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :register, _params) do
    socket
    |> assign(:form_id, "sign-up-form")
    |> assign(:cta, "Sign up")
    |> assign(:alternative_path, ~p"/sign-in")
    |> assign(:alternative, "Have an account?")
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
    |> assign(:alternative_path, ~p"/register")
    |> assign(:alternative, "Need an account?")
    |> assign(:action, ~p"/auth/user/password/sign_in")
    |> assign(
      :form,
      Form.for_action(User, :sign_in_with_password, api: CaseManager.Teams, as: "user")
    )
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="auth-page">
      <.live_component
        module={CaseManagerWeb.AuthForm}
        id={@form_id}
        form={@form}
        is_register?={@live_action == :register}
        action={@action}
        alternative={@alternative}
        alternative_path={@alternative_path}
        cta={@cta}
      />
    </div>
    """
  end
end
