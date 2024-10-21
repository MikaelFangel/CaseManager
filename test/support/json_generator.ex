defmodule CaseManagerWeb.JsonGenerator do
  @moduledoc """
  Module for generating random JSON objects of predefined max depths and lengths.
  The module attributes provides thorough test data while still letting the tests finish.
  """
  use ExUnitProperties

  @max_tree_height 10
  @max_list_length 5
  @max_map_size 10

  defp json_value(depth \\ 0)

  defp json_value(depth) when depth < @max_tree_height do
    one_of([
      string(:printable),
      integer(),
      float(),
      boolean(),
      constant(nil),
      list_of(json_value(depth + 1), max_length: @max_list_length),
      map_of(string(:printable), json_value(depth + 1), max_length: @max_map_size)
    ])
  end

  defp json_value(@max_tree_height), do: constant(%{})

  @doc """
  Generate a map representing a JSON object.
  """
  def json_map do
    map_of(string(:printable), json_value())
  end
end
