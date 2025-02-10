defmodule CaseManagerWeb.CaseLive.Show do
  @moduledoc false
  use CaseManagerWeb, :live_view

  alias CaseManager.ICM

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket), do: CaseManagerWeb.Endpoint.subscribe("comment:created")

    socket =
      socket
      |> assign(:menu_item, nil)
      |> assign(current_user: socket.assigns.current_user)
      |> assign(:alert, nil)
      |> assign(:id, nil)

    {:ok, socket, layout: {CaseManagerWeb.Layouts, :app_m0}}
  end

  @impl true
  def handle_info(
        %Phoenix.Socket.Broadcast{event: "create", payload: %Ash.Notifier.Notification{data: comment}},
        socket
      ) do
    comment = Map.put(comment, :header, nil)
    {:noreply, stream_insert(socket, :comments, comment, at: 0)}
  end

  @impl true
  def handle_params(%{"id" => id}, _uri, socket) do
    case =
      ICM.get_case_by_id!(id,
        load: [:alert, :file, :no_of_related_alerts, :comment, reporter: [:full_name]],
        actor: socket.assigns.current_user
      )

    alerts = Enum.map(case.alert, &{&1.id, &1})
    comments = case.comment |> add_date_headers() |> Enum.reverse()

    {:noreply,
     socket
     |> stream(:comments, comments)
     |> assign(case: case)
     |> assign(reporter: case.reporter)
     |> assign(related_alerts: alerts)
     |> assign(files: case.file)
     |> assign(no_of_related_alerts: case.no_of_related_alerts)}
  end

  @impl true
  def handle_event("escalate_case", %{"id" => id}, socket) do
    updated_case = ICM.escalate_case!(id, actor: socket.assigns.current_user)

    {:noreply, assign(socket, case: updated_case)}
  end

  @impl true
  def handle_event("show_modal", %{"alert_id" => alert_id}, socket) do
    alert = ICM.get_alert_by_id!(alert_id)
    socket = assign(socket, :alert, alert)

    {:noreply, socket}
  end

  @impl true
  def handle_event("hide_modal", _params, socket) do
    socket = assign(socket, :alert, nil)

    {:noreply, socket}
  end

  @impl true
  def handle_event("show_confirmation_modal", %{"id" => id}, socket) do
    socket = assign(socket, :id, id)

    {:noreply, socket}
  end

  @impl true
  def handle_event("hide_confirmation_modal", _params, socket) do
    socket = assign(socket, :id, nil)

    {:noreply, socket}
  end

  defp add_date_headers(comments, comments_with_headers \\ [], last_header \\ nil)

  defp add_date_headers([], comments_with_headers, _last_header), do: Enum.reverse(comments_with_headers)

  defp add_date_headers([%{inserted_at: inserted_at} = comment | comments], comments_with_headers, last_header) do
    header = Calendar.strftime(inserted_at, "%d. %b. %Y")

    comment = Map.put(comment, :header, if(last_header == header, do: nil, else: header))

    add_date_headers(
      comments,
      [comment | comments_with_headers],
      if(last_header == header, do: last_header, else: header)
    )
  end
end
