defmodule CaseManager.Incidents do
  @moduledoc false
  use Ash.Domain, otp_app: :case_manager, extensions: [AshPhoenix]

  resources do
    resource CaseManager.Incidents.Alert do
      define :create_alert, action: :create
      define :list_alert, action: :read
      define :get_alert, action: :read, get_by: :id
      define :update_alert, action: :update
      define :delete_alert, action: :delete
    end

    resource CaseManager.Incidents.Case
    resource CaseManager.Incidents.CaseAlert
    resource CaseManager.Incidents.Comment
    resource CaseManager.Incidents.File
  end
end
