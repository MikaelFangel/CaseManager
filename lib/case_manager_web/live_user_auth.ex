defmodule CaseManagerWeb.LiveUserAuth do
  @moduledoc """
  Helpers for authenticating users in LiveViews.
  """

  use CaseManagerWeb, :verified_routes

  import Phoenix.Component

  alias AshAuthentication.Phoenix.LiveSession

  # This is used for nested liveviews to fetch the current user.
  # To use, place the following at the top of that liveview:
  # on_mount {CaseManagerWeb.LiveUserAuth, :current_user}
  def on_mount(:current_user, _params, session, socket) do
    {:cont, LiveSession.assign_new_resources(socket, session)}
  end

  def on_mount(:live_user_optional, _params, _session, socket) do
    if socket.assigns[:current_user] do
      {:cont, socket}
    else
      {:cont, assign(socket, :current_user, nil)}
    end
  end

  def on_mount(:live_user_required, _params, _session, socket) do
    if socket.assigns[:current_user] do
      {:cont, socket}
    else
      {:halt, Phoenix.LiveView.redirect(socket, to: ~p"/sign-in")}
    end
  end

  def on_mount(:super_admin_required, _params, _session, socket) do
    user = socket.assigns[:current_user]

    with {:ok, user} <- user && Ash.load(user, :super_admin?),
         true <- user.super_admin? do
      {:cont, socket}
    else
      _error -> {:halt, Phoenix.LiveView.redirect(socket, to: ~p"/case")}
    end
  end

  def on_mount(:soc_user_required, _params, _session, socket) do
    user = socket.assigns[:current_user]

    with {:ok, user} <- user && Ash.load(user, [:super_admin?, :soc_admin?, :soc_analyst?]),
         true <- user.super_admin? || user.soc_analyst? || user.soc_admin? do
      {:cont, socket}
    else
      _error -> {:halt, Phoenix.LiveView.redirect(socket, to: ~p"/case")}
    end
  end

  def on_mount(:live_no_user, _params, _session, socket) do
    if socket.assigns[:current_user] do
      {:halt, Phoenix.LiveView.redirect(socket, to: ~p"/sign-out")}
    else
      {:cont, assign(socket, :current_user, nil)}
    end
  end
end
