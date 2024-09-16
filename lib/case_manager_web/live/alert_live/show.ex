defmodule CaseManagerWeb.AlertLive.Show do
  use CaseManagerWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <.header>
      Alert <%= @alert.title %>
      <:subtitle>This is a alert record from your database.</:subtitle>
    </.header>

    <.list>
      <:item title="Id"><%= @alert.id %></:item>
    </.list>

    <.back navigate={~p"/alerts"}>Back to alerts</.back>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:alert, Ash.get!(CaseManager.Alerts.Alert, id))}
  end

  defp page_title(:show), do: "Show Alert"
end
