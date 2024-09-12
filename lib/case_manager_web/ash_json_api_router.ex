defmodule CaseManagerWeb.AshJsonApiRouter do
  use AshJsonApi.Router,
    domains: [Module.concat(["CaseManager.Alerts"])],
    open_api: "/open_api"
end
