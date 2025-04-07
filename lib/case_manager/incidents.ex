defmodule CaseManager.Incidents do
  @moduledoc false
  use Ash.Domain, otp_app: :case_manager

  resources do
    resource CaseManager.Incidents.Alert
    resource CaseManager.Incidents.Case
    resource CaseManager.Incidents.CaseAlert
    resource CaseManager.Incidents.Comment
    resource CaseManager.Incidents.File
  end
end
