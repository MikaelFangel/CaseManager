defmodule CaseManager.AppConfig do
  @moduledoc """
  Domain that controls everything related to app configuration.
  """
  use Ash.Domain,
    extensions: [AshAdmin.Domain]

  admin do
    show?(true)
  end

  resources do
    resource(CaseManager.AppConfig.Setting)
  end
end
