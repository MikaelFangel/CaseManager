defmodule CaseManagerWeb.CaseLive.Show do
  use CaseManagerWeb, :live_view
  alias CaseManager.Cases.Case

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:menu_item, nil)

    {:ok, socket, layout: {CaseManagerWeb.Layouts, :app_m0}}
  end

  @impl true
  def handle_params(%{"id" => id}, _session, socket) do
    case = Case |> Ash.get!(id)
    alerts = Ash.load!(case, :alert).alert |> Enum.map(&{&1.id, &1})

    {:noreply,
     socket
     |> assign(case: case)
     |> assign(selected_alerts: alerts)}
  end
end
