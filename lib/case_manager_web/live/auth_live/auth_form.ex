defmodule CaseManagerWeb.AuthForm do
  @moduledoc """
  LiveComponent to show authentication form.
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
      |> assign(trigger_action: false)
      |> assign(:background_img, Helpers.load_bg())

    {:ok, socket}
  end

  @impl true
  def handle_event("validate", %{"user" => params}, socket) do
    form = Form.validate(socket.assigns.form, params, errors: false)

    {:noreply, assign(socket, form: form)}
  end

  @impl true
  def handle_event("submit", %{"user" => params}, socket) do
    form = Form.validate(socket.assigns.form, params)

    socket =
      socket
      |> assign(:form, form)
      |> assign(:errors, Form.errors(form))
      |> assign(:trigger_action, form.valid?)

    if socket.assigns[:is_onboarding?] do
      CaseManager.AppConfig.Setting
      |> Ash.Changeset.for_create(:set_setting, %{key: "onboarding_completed?", value: "true"})
      |> Ash.create!()
    end

    {:noreply, socket}
  end
end
