defmodule CaseManagerWeb.LiveUserAuth do
  @moduledoc """
  Helpers for authenticating users in LiveViews.
  """

  use CaseManagerWeb, :verified_routes

  import Phoenix.Component

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
    case socket.assigns[:current_user][:team_type] do
      :mssp -> {:cont, socket}
      _other -> {:halt, Phoenix.LiveView.redirect(socket, to: ~p"/")}
    end
  end

  def on_mount(:live_admin_user, _params, _session, socket) do
    case socket.assigns[:current_user][:role] do
      :admin -> {:cont, socket}
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
