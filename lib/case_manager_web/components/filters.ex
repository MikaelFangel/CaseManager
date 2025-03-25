defmodule CaseManagerWeb.Filters do
  @moduledoc false
  use Phoenix.Component

  import CaseManagerWeb.Input

  def team_filter(assigns) do
    ~H"""
    <.filter_input id="team-filter" options={team_options(@current_user)} selected={@selected} />
    """
  end

  def filter_input(assigns) do
    ~H"""
    <.input
      type="select"
      id={@id}
      name={@id}
      options={@options}
      value={@selected}
      class="px-2 py-0.5 !w-fit !inline-block pr-8 text-sm"
    />
    """
  end

  defp team_options(current_user) do
    [
      {"All teams", ""}
      | [actor: current_user] |> CaseManager.Teams.list_teams!() |> Enum.map(&{&1.name, &1.name}) |> Enum.uniq()
    ]
  end
end
