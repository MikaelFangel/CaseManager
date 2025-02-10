defmodule CaseManagerWeb.AshJsonApiRouter do
  @moduledoc """
  JsonApi Router for CaseManager
  """
  use AshJsonApi.Router,
    domains: [Module.safe_concat(["CaseManager.ICM"])],
    open_api: "/open_api",
    open_api_title: "CaseManager API Documentation"
end
