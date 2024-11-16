defmodule CaseManagerWeb.CaseLive.Edit do
  use CaseManagerWeb, :live_view
  alias AshPhoenix.Form
  alias CaseManager.Cases.Case

  @impl true
  def mount(%{"id" => id} = _params, _session, socket) do
    case = Case |> Ash.get!(id) |> Ash.load!([:alert, :file])
    related_alerts = case.alert |> Enum.map(&{&1.id, &1})

    form =
      case
      |> Form.for_update(:update, forms: [auto?: true], actor: socket.assigns[:current_user])
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
end
