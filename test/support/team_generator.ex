defmodule CaseManagerWeb.TeamGenerator do
  @moduledoc """
  Generator for the team respource. This can be used to generate random team data either
  for test or for display.
  """
  use ExUnitProperties

  @doc """
  Gives a list of the allowed types for a team.
  """
  def valid_types, do: ["Customer", "MSSP"]

  @doc """
  Generator that generates valid types for a team.
  """
  def type, do: StreamData.member_of(valid_types())

  @doc """
  A generator for team attributes. The generator generates a map with the following keys:
  name and type. The values for the keys are generated randomly.
  """
  def team_attrs do
    gen all(
          name <- StreamData.string(:printable, min_length: 1),
          type <- type()
        ) do
      %{
        name: name,
        type: type
      }
    end
  end
end
