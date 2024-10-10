defmodule CaseManager.Policies.CaseOwnerPolicy do
  @moduledoc """
  Implementation of the SimpleCheck behaviour. This policy checks if a given case and user team_id is the same.
  """
  use Ash.Policy.SimpleCheck
  alias CaseManager.Cases.Case
  alias CaseManager.Teams.User

  @impl true
  def describe(_options) do
    "check that the actor team id matches that of a case"
  end

  @impl true
  def match?(
        %User{team_id: team_id} = _actor,
        %{changeset: changeset} = _context,
        _opts
      ) do
    case_id = Ash.Changeset.get_attribute(changeset, :case_id)
    case = Case |> Ash.get!(case_id)

    case.team_id == team_id
  end

  @impl true
  def match?(_actor, _changeset, _opts), do: false
end
