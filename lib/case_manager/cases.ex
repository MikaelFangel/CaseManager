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
    resource CaseManager.Cases.Case
    resource CaseManager.Cases.Comment
    resource CaseManager.Cases.File
    resource CaseManager.Relationships.CaseAlert
  end
end
