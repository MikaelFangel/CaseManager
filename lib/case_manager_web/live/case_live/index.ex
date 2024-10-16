defmodule CaseManagerWeb.CaseLive.Index do
  use CaseManagerWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket), do: CaseManagerWeb.Endpoint.subscribe("case:created")
    CaseManager.SelectedAlerts.drop_selected_alerts(socket.assigns.current_user.id)

    cases_page =
      CaseManager.Cases.Case
      |> Ash.Query.sort(inserted_at: :desc)
      |> Ash.read!()

    cases = cases_page.results

    {:ok,
     stream(
       socket,
       :cases,
       cases
     )
     |> assign(:current_page, cases_page)
     |> assign(:more_pages?, cases_page.more?)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Cases")
  end

  @impl true
  def handle_info(
        %Phoenix.Socket.Broadcast{
          event: "create",
          payload: %Ash.Notifier.Notification{data: case}
        },
        socket
      ) do
    {:noreply, stream_insert(socket, :cases, case, at: 0)}
  end

  @impl true
  def handle_event("load_more_cases", _params, socket) do
    current_page = socket.assigns.current_page
    next_page = Ash.page!(current_page, :next)

    cases = next_page.results

    {:noreply,
     stream(
       socket,
       :cases,
       cases
     )
     |> assign(:current_page, next_page)
     |> assign(:more_pages?, next_page.more?)}
  end
end
