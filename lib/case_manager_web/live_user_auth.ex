defmodule CaseManagerWeb.LiveUserAuth do
  @moduledoc """
  Helpers for authenticating users in LiveViews.
  """

  use CaseManagerWeb, :verified_routes

  import Phoenix.Component

  alias CaseManager.Teams.User

  def on_mount(:live_user_optional, _params, _session, socket) do
    case socket.assigns[:current_user] do
      nil -> {:cont, assign(socket, :current_user, nil)}
      _present -> {:cont, socket}
    end
  end

  def on_mount(:live_user_required, _params, _session, socket) do
    case socket.assigns[:current_user] do
      nil -> {:halt, Phoenix.LiveView.redirect(socket, to: ~p"/sign-in")}
      _present -> {:cont, socket}
    end
  end

  def on_mount(:live_mssp_user, _params, _session, socket) do
    with %User{} = user <- socket.assigns[:current_user],
         true <- user.role in [:admin, :soc_admin, :soc_analyst] do
      {:cont, socket}
    else
      _other -> {:halt, Phoenix.LiveView.redirect(socket, to: ~p"/")}
    end
  end

  def on_mount(:live_admin_user, _params, _session, socket) do
    with %User{} = user <- socket.assigns[:current_user],
         :admin <- user.role do
      {:cont, socket}
    else
      _other -> {:halt, Phoenix.LiveView.redirect(socket, to: ~p"/")}
    end
  end

  def on_mount(:live_admin_mssp_user, params, session, socket) do
    with {:cont, _socket} <- on_mount(:live_mssp_user, params, session, socket),
         {:cont, _socket} <- on_mount(:live_admin_user, params, session, socket) do
      {:cont, socket}
    else
      _other -> {:halt, Phoenix.LiveView.redirect(socket, to: ~p"/")}
    end
  end

  def on_mount(:live_no_user, _params, _session, socket) do
    case socket.assigns[:current_user] do
      nil -> {:cont, assign(socket, :current_user, nil)}
      _present -> {:halt, Phoenix.LiveView.redirect(socket, to: ~p"/")}
    end
  end
end
