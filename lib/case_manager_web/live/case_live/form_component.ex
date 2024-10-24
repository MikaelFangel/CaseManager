defmodule CaseManagerWeb.CaseLive.FormComponent do
  use CaseManagerWeb, :live_component
  alias AshPhoenix.Form

  def update(assigns, socket) do
    form =
      CaseManager.Cases.Case
      |> Form.for_create(:create,
        forms: [
          case: [
            resource: CaseManager.Cases.Case,
            create_action: :create,
            actor: assigns[:current_user]
          ]
        ],
        domain: CaseManager.Cases
      )
      |> Form.add_form([:case])
      |> to_form()

    {:ok,
     assign(socket, :form, form)
     |> assign(:selected_alerts, assigns[:selected_alerts] || [])
     |> assign(:current_user, assigns[:current_user]) || nil}
  end

  def handle_event("validate", params, socket) do
    form = Form.validate(socket.assigns.form, params)
    {:noreply, assign(socket, form: form)}
  end

  def handle_event("save", params, socket) do
    team_id =
      socket.assigns.selected_alerts |> Enum.at(0) |> elem(1) |> Map.get(:team) |> Map.get(:id)

    selected_alert_ids =
      socket.assigns.selected_alerts
      |> Enum.map(fn {_id, alert} -> alert.id end)

    params =
      Map.put(params, :team_id, team_id)
      |> Map.put(:escalated, false)
      |> Map.put(:alert, selected_alert_ids)

    action_opts = [actor: socket.assigns.current_user]

    case AshPhoenix.Form.submit(socket.assigns.form, params: params, action_opts: action_opts) do
      {:ok, _result} ->
        {:noreply,
         socket
         |> put_flash(:info, "Case created successfully.")
         |> push_navigate(to: "/")}

      {:error, form} ->
        {:noreply, assign(socket, :form, form)}
    end
  end
end
