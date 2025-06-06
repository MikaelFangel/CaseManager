defmodule CaseManagerWeb.Plugs.ConditionalApiKey do
  @moduledoc """
  A plug that conditionally applies API key authentication.

  Skips API key authentication for documentation endpoints like 
  OpenAPI spec and Swagger UI, but requires it for actual data endpoints.
  """

  alias AshAuthentication.Strategy.ApiKey.Plug
  alias CaseManager.Accounts.User

  def init(opts) do
    # Initialize the API key plug with required options
    api_key_opts = Plug.init([resource: User, required?: true] ++ opts)
    %{api_key_opts: api_key_opts}
  end

  def call(conn, %{api_key_opts: api_key_opts}) do
    if skip_api_key_auth?(conn) do
      conn
    else
      Plug.call(conn, api_key_opts)
    end
  end

  # List of paths that should skip API key authentication
  defp skip_api_key_auth?(conn) do
    case conn.request_path do
      "/api/json/open_api" ->
        true

      "/api/json/swaggerui" ->
        true

      path when is_binary(path) ->
        String.starts_with?(path, "/api/json/swaggerui") or
          String.contains?(path, "open_api") or
          String.contains?(path, "json_schema")

      _ ->
        false
    end
  end
end
