defmodule CaseManagerWeb.CaseLive.Show do
  use CaseManagerWeb, :live_view
  alias CaseManager.Cases.Case

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:menu_item, nil)
      |> assign(current_user: socket.assigns.current_user)

    {:ok, socket, layout: {CaseManagerWeb.Layouts, :app_m0}}
  end

  @impl true
  def handle_params(%{"id" => id}, _uri, socket) do
    case = Case |> Ash.get!(id)
    loaded_relations = case |> Ash.load!([:alert, :comment])
    alerts = loaded_relations.alert |> Enum.map(&{&1.id, &1})
    comments = loaded_relations.comment

    {:noreply,
     socket
     |> assign(case: case)
     |> assign(selected_alerts: alerts)
     |> assign(comments: comments)}
  end

  @impl true
  def handle_event("escalate_case", %{"id" => id}, socket) do
    updated_case =
      Case
      |> Ash.get!(id)
      |> Ash.Changeset.for_update(:update, %{escalated: true}, actor: socket.assigns.current_user)
      |> Ash.update!()

    {:noreply, socket |> assign(case: updated_case)}
  end
end
