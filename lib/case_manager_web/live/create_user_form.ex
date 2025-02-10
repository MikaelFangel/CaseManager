defmodule CaseManagerWeb.CreateUserForm do
  @moduledoc """
  LiveComponent to show a form for creating a user.
  """
  use CaseManagerWeb, :live_component
  use PhoenixHTMLHelpers

  alias AshPhoenix.Form
  alias CaseManagerWeb.Helpers

  @impl true
  def update(assigns, socket) do
    socket =
      socket
      |> assign(assigns)
      |> assign(:current_user, Ash.load!(assigns.current_user, :team))
      |> assign(:action, ~p"/auth/user/password/register")
      |> assign(trigger_action: false)
      |> assign(:background_img, Helpers.load_bg())

    {:ok, socket}
  end

  @impl true
  def handle_event("validate", %{"form" => params}, socket) do
    form = Form.validate(socket.assigns.form, params)

    {:noreply, assign(socket, form: form)}
  end

  @impl true
  def handle_event("validate", %{"user" => params}, socket) do
    form = Form.validate(socket.assigns.form, params, errors: false)

    {:noreply, assign(socket, form: form)}
  end

  @impl true
  def handle_event("save", %{"form" => params}, socket) do
    form = socket.assigns.form

    case AshPhoenix.Form.submit(form, params: params) do
      {:ok, _user} ->
        send(self(), {:saved_user, params})
        {:noreply, socket}

      {:error, form} ->
        # Set the flash in the parent LiveView
        send(self(), {:set_flash, :error, gettext("User save error.")})

        {:noreply, assign(socket, :form, form)}
    end
  end

  @impl true
  def handle_event("save", %{"user" => params}, socket) do
    form = Form.validate(socket.assigns.form, params)
    if form.source.valid?, do: CaseManager.AppConfig.add_setting!("onboarding_completed?", "true")

    socket =
      socket
      |> assign(:form, form)
      |> assign(:errors, Form.errors(form.source))
      |> assign(:trigger_action, form.source.valid?)

    {:noreply, socket}
  end
end
