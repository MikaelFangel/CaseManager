defmodule CaseManager.Incidents do
  @moduledoc false
  use Ash.Domain, otp_app: :case_manager, extensions: [AshJsonApi.Domain, AshAdmin.Domain, AshPhoenix]

  alias CaseManager.Incidents.Alert
  alias CaseManager.Incidents.Case

  admin do
    show? true
  end

  json_api do
    routes do
      base_route "/alert", Alert do
        index :read
        get :read
        post :create
        patch :update
      end

      base_route "/case", Case do
        index :read
        get :read
        post :create
        patch :update
      end
    end
  end

  resources do
    resource Alert do
      define :create_alert, action: :create
      define :list_alert, action: :read, default_options: [load: :company, query: [sort: [creation_time: :desc]]]
      define :get_alert, action: :read, get_by: :id
      define :update_alert, action: :update
      define :delete_alert, action: :delete
      define :add_comment_to_alert, action: :add_comment, args: [:body]
      define :change_alert_status, action: :change_status, args: [:status]

      define :search_alerts,
        action: :search,
        args: [:query],
        default_options: [load: :company, query: [sort: [creation_time: :desc]]]
    end

    resource Case do
      define :create_case, action: :create
      define :list_case, action: :read, default_options: [load: :company, query: [sort: [updated_at: :desc]]]
      define :get_case, action: :read, get_by: :id
      define :update_case, action: :update
      define :delete_case, action: :delete
      define :add_comment_to_case, action: :add_comment, args: [:comment]

      define :search_cases,
        action: :search,
        args: [:query],
        default_options: [load: :company, query: [sort: [updated_at: :desc]]]
    end

    resource CaseManager.Incidents.CaseAlert

    resource CaseManager.Incidents.Comment do
      define :get_comments_for_case,
        action: :get_comments_for_case,
        args: [:case_id, :visibility],
        default_options: [load: [user: [:full_name]], query: [sort: [inserted_at: :desc]]]
    end

    resource CaseManager.Incidents.File
  end

  domain do
    description "Domain for incidents where alerts is send and cases is incidents build on top of alerts."
  end
end
