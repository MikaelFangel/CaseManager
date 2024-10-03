defmodule CaseManagerWeb.UserGenerator do
  @moduledoc """
  """
  use ExUnitProperties

  @doc """
  """
  def valid_roles, do: ["Admin", "Analyst"]

  @doc """
  """
  def role, do: StreamData.member_of(valid_roles())

  @doc """
  """
  def user_attrs do
    gen all(
          firt_name <- StreamData.string(:printable, min_length: 1),
          last_name <- StreamData.string(:printable, min_length: 1),
          role <- role()
        ) do
      %{
        first_name: firt_name,
        last_name: last_name,
        role: role
      }
    end
  end
end
