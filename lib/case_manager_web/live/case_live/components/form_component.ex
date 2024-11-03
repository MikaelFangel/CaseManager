defmodule CaseManagerWeb.CaseLive.FormComponent do
  use CaseManagerWeb, :live_component
  alias AshPhoenix.Form

  def update(assigns, socket) do
    socket =
      socket
      |> assign(:current_user, assigns[:current_user])
      |> assign(:team_name, assigns[:team_name])
      |> assign(:related_alerts, assigns[:related_alerts])
      |> assign(:form, assigns[:form])
      |> assign(:on_cancel, assigns[:on_cancel])

    {:ok, socket}
  end

  def handle_event("validate", params, socket) do
    form = Form.validate(socket.assigns.form, params)
    {:noreply, assign(socket, form: form)}
  end

  def handle_event("save", params, socket) do
    team_id =
      socket.assigns.related_alerts
      |> Enum.at(0)
      |> elem(1)
      |> Map.get(:team)
      |> Map.get(:id)

    related_alert_ids =
      socket.assigns.related_alerts
      |> Enum.map(fn {_id, alert} -> alert.id end)

    params =
      Map.put(params, :team_id, team_id)
      |> Map.put(:escalated, false)
      |> Map.put(:alert, related_alert_ids)

    action_opts = [actor: socket.assigns.current_user]

    case AshPhoenix.Form.submit(socket.assigns.form, params: params, action_opts: action_opts) do
      {:ok, case} ->
        socket =
          socket
          |> put_flash(:info, gettext("Case created successfully."))
          |> push_navigate(to: ~p"/case/#{case.id}")

        {:noreply, socket}

      {:error, form} ->
        {:noreply, assign(socket, :form, form)}
    end
  end
end
