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
      |> assign(:alert, nil)

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
    comment = Map.put(comment, :header, nil)
    {:noreply, socket |> stream_insert(:comments, comment, at: 0)}
  end

  @impl true
  def handle_params(%{"id" => id}, _uri, socket) do
    case = Case |> Ash.get!(id)
    loaded_relations = case |> Ash.load!([:alert, :comment, :file])
    alerts = loaded_relations.alert |> Enum.map(&{&1.id, &1})
    comments = loaded_relations.comment |> add_date_headers()
    files = loaded_relations.file

    comments = comments |> Enum.reverse()

    {:noreply,
     socket
     |> stream(:comments, comments)
     |> assign(case: case)
     |> assign(related_alerts: alerts)
     |> assign(files: files)}
  end

  @impl true
  def handle_event("escalate_case", %{"id" => id}, socket) do
    updated_case =
      Case
      |> Ash.get!(id)
      |> Case.escalate!(actor: socket.assigns.current_user)

    {:noreply, socket |> assign(case: updated_case)}
  end

  @impl true
  def handle_event("show_modal", %{"alert_id" => alert_id}, socket) do
    alert = Ash.get!(CaseManager.Alerts.Alert, alert_id)

    socket =
      socket
      |> assign(:alert, alert)

    {:noreply, socket}
  end

  @impl true
  def handle_event("hide_modal", _params, socket) do
    socket =
      socket
      |> assign(:alert, nil)

    {:noreply, socket}
  end

  defp add_date_headers(comments, comments_with_headers \\ [], last_header \\ nil)

  defp add_date_headers([], comments_with_headers, _last_header),
    do: Enum.reverse(comments_with_headers)

  defp add_date_headers(
         [%{inserted_at: inserted_at} = comment | comments],
         comments_with_headers,
         last_header
       ) do
    header = Calendar.strftime(inserted_at, "%d. %b. %Y")

    comment =
      comment
      |> Map.put(:header, if(last_header == header, do: nil, else: header))

    add_date_headers(
      comments,
      [comment | comments_with_headers],
      if(last_header == header, do: last_header, else: header)
    )
  end
end
