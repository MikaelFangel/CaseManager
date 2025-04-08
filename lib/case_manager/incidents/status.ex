defmodule CaseManager.Incidents.Status do
  @moduledoc false
  use Ash.Type.Enum, values: [:new, :reviewed, :false_positive, :linked_to_case]
end
