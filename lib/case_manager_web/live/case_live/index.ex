defmodule CaseManagerWeb.CaseLive.Index do
  @moduledoc false
  use CaseManagerWeb, :live_view

  alias CaseManager.Incidents

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        <:actions>
          <.button variant="primary" navigate={~p"/case/new"}>
            <.icon name="hero-plus" /> New Case
          </.button>
        </:actions>
      </.header>

      <.table id="cases" rows={@streams.cases} row_click={fn {_id, case} -> JS.navigate(~p"/case/#{case}") end}>
        <:col :let={{_id, case}} label="Company"></:col>
        <:col :let={{_id, case}} label="Title">{case.title}</:col>
        <:col :let={{_id, case}} label="Priority">{case.priority}</:col>
        <:col :let={{_id, case}} label="Case ID">{case.id}</:col>
        <:col :let={{_id, case}} label="Status">{case.status}</:col>
        <:col :let={{_id, case}} label="Assignee">{case.assignee}</:col>
      </.table>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Listing Cases")
     |> stream(:cases, Incidents.list_case!())}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    case = Incidents.get_case!(id)
    {:ok, _} = Incidents.delete_case(case)

    {:noreply, stream_delete(socket, :cases, case)}
  end
end
