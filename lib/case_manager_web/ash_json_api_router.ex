defmodule CaseManagerWeb.AshJsonApiRouter do
  use AshJsonApi.Router,
    domains: [CaseManager.Incidents],
    open_api: "/open_api",
    open_api_title: "CaseManager API Documentation",
    open_api_version: to_string(Application.spec(:case_manager, :vsn))
end
