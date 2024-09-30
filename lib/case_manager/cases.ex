defmodule CaseManager.Cases do
  use Ash.Domain

  resources do
    resource CaseManager.Cases.Case
    resource CaseManager.Relationships.CaseAlert
  end
end
