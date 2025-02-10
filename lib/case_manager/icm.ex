defmodule CaseManager.ICM do
  @moduledoc """
  Incident case management (ICM) represents the domain with the alerts and the related case management
  hereunder the documentation of the investigations.
  """
  use Ash.Domain,
    extensions: [AshJsonApi.Domain, AshAdmin.Domain]

  alias CaseManager.ICM.Alert

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

    resource CaseManager.ICM.Case do
      define :escalate_case, args: [], action: :escalate
      define :upload_file_to_case, args: [:file], action: :upload_file
      define :add_comment_to_case, args: [:body], action: :add_comment
      define :remove_alert_from_case, args: [:alert_id], action: :remove_alert
      define :assign_case, args: [:assignee], action: :set_assignee
    end

    resource CaseManager.ICM.CaseAlert
    resource CaseManager.ICM.Comment
    resource CaseManager.ICM.File
  end
end
