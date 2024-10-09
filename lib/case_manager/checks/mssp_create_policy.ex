defmodule CaseManager.Policies.MSSPCreatePolicy do
  use Ash.Policy.SimpleCheck

  def describe(_options) do
    "check that the actor is part of a MSSP team"
  end

  def match?(
        %CaseManager.Teams.User{} = actor,
        _context,
        _opts
      ) do
    team = Ash.load!(actor, :team).team
    team && team.type == :mssp
  end

  def match?(_actor, _changeset, _opts), do: false
end
