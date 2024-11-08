defmodule CaseManagerWeb.Plugs.Onboarding do
  @moduledoc """
  Checks if the onboarding workflow should be run,
  """
  import Plug.Conn

  def init(default), do: default

  def call(conn, _opts) do
    case Ash.get(CaseManager.AppConfig.Setting, "onboarding_completed?") do
      {:ok, %{value: "true"}} ->
        conn
        |> Phoenix.Controller.redirect(to: "/")
        |> halt()

      _unexpected ->
        conn
    end
  end
end
