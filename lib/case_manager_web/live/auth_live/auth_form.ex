defmodule CaseManagerWeb.AuthForm do
  @moduledoc """
  LiveComponent to show authentication form.
  """
  use CaseManagerWeb, :live_component
  use PhoenixHTMLHelpers
  alias AshPhoenix.Form

  @impl true
  def update(assigns, socket) do
    socket =
      socket
      |> assign(assigns)
      |> assign(trigger_action: false)

    {:ok, socket}
  end

  @impl true
  def handle_event("validate", %{"user" => params}, socket) do
    form = socket.assigns.form |> Form.validate(params, errors: false)

    {:noreply, assign(socket, form: form)}
  end

  @impl true
  def handle_event("submit", %{"user" => params}, socket) do
    form = socket.assigns.form |> Form.validate(params)

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
