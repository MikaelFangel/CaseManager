defmodule CaseManager.Teams.Secrets do
  use AshAuthentication.Secret

  def secret_for([:authentication, :tokens, :signing_secret], CaseManager.Teams.User, _) do
    case Application.fetch_env(:case_manager, CaseManager.Endpoint) do
      {:ok, endpoint_config} ->
        Keyword.fetch(endpoint_config, :secret_key_base)

      :error ->
        :error
    end
  end
end
