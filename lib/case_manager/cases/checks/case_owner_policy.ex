defmodule CaseManager.Policies.CaseOwnerPolicy do
  use Ash.Policy.SimpleCheck

  def describe(_options) do
    "check that the actor team id matches that of a case"
  end

  def match?(
        %CaseManager.Teams.User{team_id: team_id} = _actor,
        %{changeset: changeset} = _context,
        _opts
      ) do
    case_id = Ash.Changeset.get_attribute(changeset, :case_id)
    case = CaseManager.Cases.Case.get_by_id!(case_id)

    case.team_id == team_id
  end

  def match?(_actor, _changeset, _opts), do: false
end
