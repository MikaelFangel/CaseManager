defmodule CaseManager.Organizations.SOCRoles do
  @moduledoc false
  use Ash.Type.Enum, values: [:super_admin, :admin, :analyst]
end
