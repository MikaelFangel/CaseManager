defmodule CaseManagerWeb.UsersLive.Index do
  use CaseManagerWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    users = CaseManager.Teams.User |> Ash.read!() |> Ash.load!(:full_name)
    socket = socket |> assign(:menu_item, :users) |> assign(:users, users)

    {:ok, socket}
  end
end
