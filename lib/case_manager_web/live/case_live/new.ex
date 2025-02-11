defmodule CaseManagerWeb.CaseLive.New do
  @moduledoc false
  use CaseManagerWeb, :live_view

  alias CaseManager.ICM
  alias CaseManager.SelectedAlerts
  alias CaseManager.Teams

  @impl true
  def mount(_params, _session, socket) do
    selected_alerts =
      socket.assigns.current_user.id
      |> CaseManager.SelectedAlerts.get_selected_alerts()
      |> Enum.map(fn alert_id -> {alert_id, ICM.get_alert_by_id!(alert_id)} end)

    # Redirect users if they try to access the page through the URL without selecting any alerts
    # else assign the selected alerts to the socket and render the page.
    case selected_alerts do
      [] ->
        {:ok, push_navigate(socket, to: ~p"/alerts")}

      _alerts ->
        first_team = fn
          [{_id, alert} | _rest] -> alert.team
          _empty -> nil
        end

        form =
          selected_alerts
          |> first_team.()
          |> Teams.form_to_add_case_to_team(actor: socket.assigns[:current_user])
          |> to_form()

        socket =
          socket
          |> assign(:menu_item, nil)
          |> assign(:current_user, socket.assigns.current_user)
          |> assign(:team_name, first_team.(selected_alerts).name)
          |> assign(:team_id, first_team.(selected_alerts).id)
          |> assign(:related_alerts, selected_alerts)
          |> assign(:form, form)

        {:ok, socket, layout: {CaseManagerWeb.Layouts, :app_m0}}
    end
  end

  @impl true
  def handle_event("remove_alert", %{"alert_id" => alert_id}, socket) do
    socket =
      if length(socket.assigns.related_alerts) > 1 do
        SelectedAlerts.toggle_alert_selection(
          socket.assigns.current_user.id,
          alert_id,
          socket.assigns.team_id
        )

        selected_alerts =
          socket.assigns.current_user.id
          |> CaseManager.SelectedAlerts.get_selected_alerts()
          |> Enum.map(fn alert_id -> {alert_id, ICM.get_alert_by_id!(alert_id)} end)

        assign(socket, :related_alerts, selected_alerts)
      else
        put_flash(socket, :error, gettext("You can't delete the last alert."))
      end

    {:noreply, socket}
  end
end
