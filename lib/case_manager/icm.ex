defmodule CaseManager.ICM do
  @moduledoc """
  Incident case management (ICM) represents the domain with the alerts and the related case management
  hereunder the documentation of the investigations.
  """
  use Ash.Domain,
    extensions: [AshJsonApi.Domain, AshAdmin.Domain, AshPhoenix]

  alias CaseManager.ICM

  json_api do
    routes do
      base_route "/alert", ICM.Alert do
        index :read_paginated
        get :read
        post :create

        patch :update_additional_data do
          route "/:id/additional_data"
        end

        patch :add_enrichment do
          route "/:id/enrichment"
        end
      end

      base_route "/case", ICM.Case do
        index :read_paginated
        get :read
        post :create

        patch :escalate do
          route "/:id/escalate/"
        end

        patch :update
      end
    end
  end

  admin do
    show?(true)
  end

  domain do
    description """
    Resources related to incident case management (ICM).
    """
  end

  resources do
    resource ICM.Alert do
      define :add_alert, action: :create
      define :update_additional_data_on_alert, action: :update_additional_data
      define :get_alert_by_id, action: :read, get_by: :id, default_options: [load: [:team]]
      define :add_enrichment_to_alert, action: :add_enrichment

      define :list_alerts,
        action: :read_paginated,
        default_options: [query: [sort_input: "-inserted_at", load: [:team, :case]]]
    end

    resource ICM.Case do
      define :get_case_by_id, action: :read_paginated, get_by: :id

      define :list_cases,
        action: :read_paginated,
        default_options: [query: [sort_input: "-inserted_at", load: [assignee: :full_name]]]

      define :escalate_case, action: :escalate, get_by: :id
      define :view_case, args: [:time], action: :view
      define :upload_file_to_case, args: [:file], action: :upload_file
      define :add_comment_to_case, args: [:body], action: :add_comment
      define :remove_alert_from_case, args: [:alert_id], action: :remove_alert
      define :assign_case, args: [:assignee], action: :set_assignee
    end

    resource ICM.Alert.Enrichment do
      define :get_enrichment_by_id, action: :read, get_by: :id
      define :update_enrichment, action: :update
      define :remove_enrichment, action: :destroy
      define :list_enrichments, action: :read
    end

    resource ICM.CaseAlert
    resource ICM.Comment
    resource ICM.File
    resource ICM.Case.View
    resource ICM.CaseView
  end
end
