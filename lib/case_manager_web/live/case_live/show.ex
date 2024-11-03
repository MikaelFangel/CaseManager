defmodule CaseManagerWeb.CaseLive.Show do
  use CaseManagerWeb, :live_view
  alias CaseManager.Cases.Case

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket), do: CaseManagerWeb.Endpoint.subscribe("comment:created")

    socket =
      socket
      |> assign(:menu_item, nil)
      |> assign(current_user: socket.assigns.current_user)

    {:ok, socket, layout: {CaseManagerWeb.Layouts, :app_m0}}
  end

  @impl true
  def handle_info(
        %Phoenix.Socket.Broadcast{
          event: "create",
          payload: %Ash.Notifier.Notification{data: comment}
        },
        socket
      ) do
    {:noreply, socket |> stream_insert(:comments, comment, at: 0)}
  end

  @impl true
  def handle_params(%{"id" => id}, _uri, socket) do
    case = Case |> Ash.get!(id)
    loaded_relations = case |> Ash.load!([:alert, :comment])
    alerts = loaded_relations.alert |> Enum.map(&{&1.id, &1})
    comments = loaded_relations.comment

    comments = comments |> Enum.reverse()

    {:noreply,
     socket
     |> stream(
       :comments,
       comments
     )
     |> assign(case: case)
     |> assign(related_alerts: alerts)}
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

  def newline_to_br(text) do
    text
    |> String.split("\n")
    |> Enum.map_join("<br/>", & &1)
    |> raw()
  end
end
