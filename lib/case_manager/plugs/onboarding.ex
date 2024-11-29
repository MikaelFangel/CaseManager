defmodule CaseManagerWeb.Plugs.Onboarding do
  @moduledoc """
  Checks if the onboarding workflow should be run,
  """
  import Plug.Conn

  alias CaseManager.AppConfig.Setting

  def init(default), do: default

  def call(conn, _opts) do
    case Ash.get(Setting, %{key: "onboarding_completed?"}) do
      {:ok, %Setting{value: "true"}} ->
        conn
        |> Phoenix.Controller.redirect(to: "/")
        |> halt()

      {:ok, %Setting{value: "false"}} ->
        conn

      {:error, %Ash.Error.Invalid{errors: [%Ash.Error.Query.NotFound{}]}} ->
        conn
    end
  end
end
