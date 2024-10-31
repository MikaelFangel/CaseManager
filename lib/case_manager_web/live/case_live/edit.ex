defmodule CaseManagerWeb.CaseLive.Edit do
  use CaseManagerWeb, :live_view
  alias AshPhoenix.Form

  @impl true
  def mount(%{"id" => id} = _params, _session, socket) do
    case = CaseManager.Cases.Case |> Ash.get!(id)

    form =
      case
      |> Form.for_update(:update,
        forms: [
          case: [
            resource: CaseManager.Cases.Case,
            data: case,
            create_action: :create,
            update_action: :update,
            actor: socket.assigns[:current_user]
          ]
        ],
        domain: CaseManager.Cases
      )
      |> to_form()

    socket =
      socket
      |> assign(:menu_item, nil)
      |> assign(:case_id, id)
      |> assign(:form, form)

    {:ok, socket, layout: {CaseManagerWeb.Layouts, :app_m0}}
  end
end