defmodule CaseManager.Teams.Role do
  @moduledoc false
  use Ash.Type.Enum, values: [:admin, :soc_admin, :team_admin, :soc_analyst, :team_member, :service_account]

  def assignable_values(:admin), do: values()
  def assignable_values(:soc_admin), do: Enum.reject(values(), &(&1 == :admin))
  def assignable_values(:team_admin), do: [:team_admin, :team_member]
  def assignable_values(_role), do: nil
end
