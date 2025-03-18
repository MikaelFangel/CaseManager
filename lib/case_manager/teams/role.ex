defmodule CaseManager.Teams.Role do
  @moduledoc false
  use Ash.Type.Enum, values: [:admin, :soc_admin, :team_admin, :soc_analyst, :team_member, :service_account]
end
