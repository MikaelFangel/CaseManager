defmodule CaseManagerWeb.LiveUserAuth do
  @moduledoc """
  Helpers for authenticating users in LiveViews.
  """

  import Phoenix.Component
  use CaseManagerWeb, :verified_routes

  def on_mount(:live_user_optional, _params, _session, socket) do
    socket.assigns[:current_user]
    |> case do
      true -> {:cont, socket}
      _ -> {:cont, assign(socket, :current_user, nil)}
    end
  end

  def on_mount(:live_user_required, _params, _session, socket) do
    socket.assigns[:current_user]
    |> case do
      true -> {:cont, socket}
      _ -> {:halt, Phoenix.LiveView.redirect(socket, to: ~p"/sign-in")}
    end
  end

  def on_mount(:live_no_user, _params, _session, socket) do
    socket.assigns[:current_user]
    |> case do
      true -> {:halt, Phoenix.LiveView.redirect(socket, to: ~p"/")}
      _ -> {:cont, assign(socket, :current_user, nil)}
    end
  end
end
