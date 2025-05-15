defmodule CaseManager.Incidents.Severity do
  @moduledoc false
  use Ash.Type.Enum, values: [:info, :low, :medium, :high, :critical]
end
