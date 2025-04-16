defmodule CaseManager.Incidents do
  @moduledoc false
  use Ash.Domain, otp_app: :case_manager, extensions: [AshAdmin.Domain, AshPhoenix]

  admin do
    show? true
  end

  resources do
    resource CaseManager.Incidents.Alert do
      define :create_alert, action: :create
      define :list_alert, action: :read, default_options: [load: :company, query: [sort: [creation_time: :desc]]]
      define :get_alert, action: :read, get_by: :id
      define :update_alert, action: :update
      define :delete_alert, action: :delete
      define :add_comment_to_alert, action: :add_comment, args: [:body]
      define :change_alert_status, action: :change_status, args: [:status]
    end

    resource CaseManager.Incidents.Case do
      define :create_case, action: :create
      define :list_case, action: :read, default_options: [load: :company, query: [sort: [updated_at: :desc]]]
      define :get_case, action: :read, get_by: :id
      define :update_case, action: :update
      define :delete_case, action: :delete
    end

    resource CaseManager.Incidents.CaseAlert
    resource CaseManager.Incidents.Comment
    resource CaseManager.Incidents.File
  end
end
