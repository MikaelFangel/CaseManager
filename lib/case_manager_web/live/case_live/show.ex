defmodule CaseManagerWeb.CaseLive.Show do
  @moduledoc false
  use CaseManagerWeb, :live_view

  alias CaseManager.Incidents

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Case {@case.id}
        <:subtitle>This is a case record from your database.</:subtitle>
        <:actions>
          <.button navigate={~p"/case"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button variant="primary" navigate={~p"/case/#{@case}/edit?return_to=show"}>
            <.icon name="hero-pencil-square" /> Edit case
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="Title">{@case.title}</:item>
      </.list>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Show Case")
     |> assign(:case, Incidents.get_case!(id))}
  end
end
