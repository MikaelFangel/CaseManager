defmodule CaseManagerWeb.UsersLive.Index do
  @moduledoc false
  use CaseManagerWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    users = Ash.read!(CaseManager.Teams.User, load: [:full_name, :team])
    socket = socket |> assign(:menu_item, :users) |> assign(:users, users)

    {:ok, socket}
  end
end
