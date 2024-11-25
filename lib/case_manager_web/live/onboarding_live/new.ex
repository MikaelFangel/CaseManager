defmodule CaseManagerWeb.OnboardingLive.New do
  @moduledoc false
  use CaseManagerWeb, :live_view

  alias AshPhoenix.Form

  @impl true
  def mount(_params, _session, socket) do
    form =
      CaseManager.Teams.Team
      |> Form.for_create(:create, forms: [auto?: true])
      |> to_form()

    socket = assign(socket, :form, form)

    {:ok, socket, layout: {CaseManagerWeb.Layouts, :onboarding}}
  end

  @impl true
  def handle_event("create", params, socket) do
    params = Map.put(params, :type, :mssp)

    case AshPhoenix.Form.submit(socket.assigns.form, params: params) do
      {:ok, _result} ->
        {:noreply, push_navigate(socket, to: ~p"/onboarding/user")}

      {:error, form} ->
        {:noreply, assign(socket, :form, form)}
    end
  end
end
