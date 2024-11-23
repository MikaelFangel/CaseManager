defmodule CaseManagerWeb.UsersLive.Index do
  use CaseManagerWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    users = CaseManager.Teams.User |> Ash.read!(load: [:full_name, :team])
    socket = socket |> assign(:menu_item, :users) |> assign(:users, users)

    {:ok, socket}
  end
end
