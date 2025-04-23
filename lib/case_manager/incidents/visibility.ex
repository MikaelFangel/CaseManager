defmodule CaseManager.Incidents.Visibility do
  @moduledoc false
  use Ash.Type.Enum, values: [:public, :internal, :personal]
end
