defmodule CaseManager.Secrets do
  @moduledoc false
  use AshAuthentication.Secret

  def secret_for([:authentication, :tokens, :signing_secret], CaseManager.Accounts.User, _opts) do
    Application.fetch_env(:case_manager, :token_signing_secret)
  end
end
