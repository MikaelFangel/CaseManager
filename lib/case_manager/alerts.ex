defmodule CaseManager.Alerts do
  @moduledoc """
  Domain that defines resources related to alerts and defines the allowed routes
  for the JSON API.
  """
  use Ash.Domain, extensions: [AshJsonApi.Domain, AshAdmin.Domain]

  alias CaseManager.Alerts.Alert

  json_api do
    routes do
      base_route "/alerts", Alert do
        post :create
        patch :update_additional_data
      end
    end
  end

  admin do
    show?(true)
  end

  resources do
    resource Alert
    resource CaseManager.Relationships.CaseAlert
  end
end
