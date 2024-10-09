defmodule CaseManager.Cases do
  @moduledoc """
  Domain to represent a case and its relations.
  """
  use Ash.Domain

  resources do
    resource CaseManager.Cases.Case
    resource CaseManager.Cases.Comment
    resource CaseManager.Relationships.CaseAlert
  end
end
