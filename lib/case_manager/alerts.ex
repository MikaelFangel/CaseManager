defmodule CaseManager.Alerts do
  @moduledoc """
  Domain that defines resources related to alerts and defines the allowed routes
  for the JSON API.
  """
  use Ash.Domain, extensions: [AshJsonApi.Domain]

  resources do
    resource CaseManager.Alerts.Alert
    resource CaseManager.Relationships.CaseAlert
  end

  json_api do
    routes do
      base_route "/alerts", CaseManager.Alerts.Alert do
        post :create
      end
    end
  end
end
