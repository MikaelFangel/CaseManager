defmodule CaseManager.Cases do
  @moduledoc """
  Domain to represent a case and its relations.
  """
  use Ash.Domain,
    extensions: [AshAdmin.Domain]

  admin do
    show?(true)
  end

  resources do
    resource CaseManager.Cases.Case do
      define :escalate_case, args: [], action: :escalate
      define :upload_file_to_case, args: [:file], action: :upload_file
      define :add_comment_to_case, args: [:body], action: :add_comment
      define :remove_alert_from_case, args: [:alert_id], action: :remove_alert
      define :assign_case, args: [:assignee], action: :set_assignee
    end

    resource CaseManager.Cases.Comment
    resource CaseManager.Cases.File
    resource CaseManager.Relationships.CaseAlert
  end
end
