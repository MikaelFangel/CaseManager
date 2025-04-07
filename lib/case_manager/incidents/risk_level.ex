defmodule CaseManager.Incidents.RiskLevel do
  @moduledoc false
  use Ash.Type.Enum, values: [:info, :low, :medium, :high, :critical]
end
