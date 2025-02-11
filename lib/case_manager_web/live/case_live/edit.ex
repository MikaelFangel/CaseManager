defmodule CaseManagerWeb.CaseLive.Edit do
  @moduledoc false
  use CaseManagerWeb, :live_view

  alias AshPhoenix.Form
  alias CaseManager.ICM

  @impl true
  def mount(%{"id" => id} = _params, _session, socket) do
    case = ICM.get_case_by_id!(id, load: [:alert, :file], actor: socket.assigns[:current_user])
    related_alerts = format_alerts(case.alert)

    form =
      case
      |> Form.for_update(:update,
        forms: [auto?: true],
        actor: socket.assigns[:current_user],
        params: %{status: case.status}
      )
      |> to_form()

    socket =
      socket
      |> assign(:menu_item, nil)
      |> assign(:id, id)
      |> assign(:team_name, case.team.name)
      |> assign(:related_alerts, related_alerts)
      |> assign(:files, case.file)
      |> assign(:form, form)

    {:ok, socket, layout: {CaseManagerWeb.Layouts, :app_m0}}
  end

  @impl true
  def handle_event("remove_alert", %{"alert_id" => alert_id}, socket) do
    socket =
      if length(socket.assigns.related_alerts) > 1 do
        case =
          ICM.remove_alert_from_case!(socket.assigns.id, alert_id, actor: socket.assigns.current_user)

        assign(socket, related_alerts: format_alerts(case.alert))
      else
        put_flash(socket, :error, gettext("You can't delete the last alert."))
      end

    {:noreply, socket}
  end

  defp format_alerts(alerts) do
    Enum.map(alerts, &{&1.id, &1})
  end
end
