defmodule CaseManager.Teams.Secrets do
  @moduledoc """
  Helper module to fetch the secret needed for Ash authentication to work.
  """
  use AshAuthentication.Secret

  def secret_for([:authentication, :token, :signing_secret], CaseManager.Teams.User, _keyword) do
    case Application.fetch_env(:case_manager, CaseManager.Endpoint) do
      {:ok, endpoint_config} ->
        Keyword.fetch(endpoint_config, :secret_key_base)

      :error ->
        :error
    end
  end
end
