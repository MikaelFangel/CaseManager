defmodule CaseManager.Teams.Token do
  @moduledoc """
  Resource representing a user token.
  """
  use Ash.Resource,
    domain: CaseManager.Teams,
    data_layer: AshPostgres.DataLayer,
    authorizers: [Ash.Policy.Authorizer],
    extensions: [AshAuthentication.TokenResource]

  postgres do
    table "token"
    repo CaseManager.Repo
  end

  policies do
    bypass AshAuthentication.Checks.AshAuthenticationInteraction do
      authorize_if always()
    end
  end
end
