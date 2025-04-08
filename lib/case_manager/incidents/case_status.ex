defmodule CaseManager.Incidents.CaseStatus do
  @moduledoc false
  use Ash.Type.Enum,
    values: [
      :new,
      :open,
      :in_progress,
      :pending,
      :resolved,
      :closed,
      :reopened
    ]
end
