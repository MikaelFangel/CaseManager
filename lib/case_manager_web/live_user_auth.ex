defmodule CaseManagerWeb.LiveUserAuth do
  @moduledoc """
  Helpers for authenticating users in LiveViews.
  """

  import Phoenix.Component
  use CaseManagerWeb, :verified_routes

  def on_mount(:live_user_optional, _params, _session, socket) do
    socket.assigns[:current_user]
    |> case do
      nil -> {:cont, assign(socket, :current_user, nil)}
      _present -> {:cont, socket}
    end
  end

  def on_mount(:live_user_required, _params, _session, socket) do
    socket.assigns[:current_user]
    |> case do
      nil -> {:halt, Phoenix.LiveView.redirect(socket, to: ~p"/sign-in")}
      _present -> {:cont, socket}
    end
  end

  def on_mount(:live_mssp_user, _params, _session, socket) do
    case Ash.load!(socket.assigns.current_user, :team).team.type do
      :mssp -> {:cont, socket}
      _ -> {:halt, Phoenix.LiveView.redirect(socket, to: ~p"/")}
    end
  end

  def on_mount(:live_no_user, _params, _session, socket) do
    socket.assigns[:current_user]
    |> case do
      nil -> {:cont, assign(socket, :current_user, nil)}
      _present -> {:halt, Phoenix.LiveView.redirect(socket, to: ~p"/")}
    end
  end
end
