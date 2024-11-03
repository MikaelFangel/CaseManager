defmodule CaseManager.Alerts do
  @moduledoc """
  Domain that defines resources related to alerts and defines the allowed routes
  for the JSON API.
  """
  use Ash.Domain, extensions: [AshJsonApi.Domain, AshAdmin.Domain]

  json_api do
    routes do
      base_route "/alerts", CaseManager.Alerts.Alert do
        post :create
        patch :update_additional_data
      end
    end
  end

  admin do
    show?(true)
  end

  resources do
    resource CaseManager.Alerts.Alert
    resource CaseManager.Relationships.CaseAlert
  end
end
