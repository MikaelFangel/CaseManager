defmodule CaseManager.Policies.MSSPCreatePolicy do
  @moduledoc """
  Implementation of the SimpleCheck behaviour. This policy checks if a user is part
  of the mssp team and if so it passes.
  """
  use Ash.Policy.SimpleCheck

  @impl true
  def describe(_options) do
    "check that the actor is part of a MSSP team"
  end

  @impl true
  def match?(%CaseManager.Teams.User{} = actor, _context, _opts) do
    team_type =
      case actor.team_type do
        %Ash.NotLoaded{} -> Ash.load!(actor, :team_type).team_type
        _loaded -> actor.team_type
      end

    team_type == :mssp
  end

  @impl true
  def match?(_actor, _changeset, _opts), do: false
end
