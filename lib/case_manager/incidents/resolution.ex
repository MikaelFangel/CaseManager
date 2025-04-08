defmodule CaseManager.Incidents.Resolution do
  @moduledoc false
  use Ash.Type.Enum,
    values: [
      :true_positive,
      :false_positive,
      :benign,
      :inconclusive
    ]
end
