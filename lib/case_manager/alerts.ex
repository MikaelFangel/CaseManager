defmodule CaseManager.Alerts do
  use Ash.Domain, extensions: [AshJsonApi.Domain]

  resources do
    resource CaseManager.Alerts.Alert
  end

  json_api do
    routes do
      base_route "/alerts", CaseManager.Alerts.Alert do
        post :create 
      end
    end
  end
end
