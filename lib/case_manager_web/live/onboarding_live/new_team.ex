defmodule CaseManagerWeb.OnboardingLive.NewTeam do
  @moduledoc false
  use CaseManagerWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    form = to_form(CaseManager.Teams.form_to_add_team(authorize?: false))

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
