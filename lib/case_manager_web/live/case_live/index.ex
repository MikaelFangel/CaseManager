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
        <:col :let={{_id, case}} label="Company">{case.company.name}</:col>
        <:col :let={{_id, case}} label="Title">{case.title}</:col>
        <:col :let={{_id, case}} label="Risk Level">
          <.badge type={risk_level_to_badge_type(case.risk_level)}>
            {case.risk_level |> to_string() |> String.capitalize()}
          </.badge>
        </:col>
        <:col :let={{_id, case}} label="Status">
          <.badge type={status_to_badge_type(case.status)} modifier="outline">
            {case.status |> to_string() |> String.split("_") |> Enum.join(" ") |> String.capitalize()}
          </.badge>
        </:col>

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

  defp risk_level_to_badge_type(level) do
    case level do
      :info -> :info
      :low -> :success
      :medium -> :warning
      :high -> :neutral
      :critical -> :error
      _ -> :neutral
    end
  end

  defp status_to_badge_type(status) do
    case status do
      :new -> :info
      :open -> :info
      :in_progress -> :warning
      :pending -> :warning
      :resolved -> :success
      :closed -> :neutral
      :reopened -> :error
      _ -> :neutral
    end
  end
end
