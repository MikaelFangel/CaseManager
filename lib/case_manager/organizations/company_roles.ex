defmodule CaseManager.Organizations.CompanyRoles do
  @moduledoc false
  use Ash.Type.Enum, values: [:admin, :analyst]
end
