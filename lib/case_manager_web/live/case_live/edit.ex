defmodule CaseManagerWeb.CaseLive.Edit do
  use CaseManagerWeb, :live_view
  alias AshPhoenix.Form

  @impl true
  def mount(%{"id" => id} = _params, _session, socket) do
    case = CaseManager.Cases.Case |> Ash.get!(id)
    related_alerts = Ash.load!(case.team, :alert) |> Map.get(:alert) |> Enum.map(&{&1.id, &1})

    form =
      case
      |> Form.for_update(:update, forms: [auto?: true])
      |> to_form()

    socket =
      socket
      |> assign(:menu_item, nil)
      |> assign(:id, id)
      |> assign(:team_name, case.team.name)
      |> assign(:related_alerts, related_alerts)
      |> assign(:form, form)

    {:ok, socket, layout: {CaseManagerWeb.Layouts, :app_m0}}
  end
end
