defmodule CaseManager.Cases do
  use Ash.Domain

  resources do
    resource CaseManager.Cases.Case
  end
end
