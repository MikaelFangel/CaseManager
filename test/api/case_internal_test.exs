defmodule CaseManager.CaseInternalTest do
  @moduledoc """
  Test cases for the internal api for the the case and comment resource.
  """
  use CaseManager.DataCase, async: true
  use ExUnitProperties
  alias CaseManager.Alerts.Alert
  alias CaseManager.Cases.{Case, Comment}
  alias CaseManager.Teams.Team
  alias CaseManagerWeb.CaseGenerator

  setup do
    team_gen =
      gen all(name <- StreamData.string(:printable, min_length: 1)) do
        {%{name: name, type: "Customer"}, %{name: name, type: "MSSP"}}
      end

    [{customer_gen_team, mssp_gen_team}] = team_gen |> Enum.take(1)

    customer_team = Team |> Ash.Changeset.for_create(:create, customer_gen_team) |> Ash.create!()
    mssp_team = Team |> Ash.Changeset.for_create(:create, mssp_gen_team) |> Ash.create!()
    %{customer: customer_team, mssp: mssp_team}
  end

  describe "positive test for creating cases" do
    property "only MSSP team can create cases", %{customer: customer_team, mssp: mssp_team} do
      check all(case_attr <- CaseGenerator.case_attrs()) do
        nil_changeset =
          Case
          |> Ash.Changeset.for_create(:create, case_attr)

        mssp_changeset =
          Case
          |> Ash.Changeset.for_create(:create, case_attr |> Map.put(:team_id, mssp_team.id))

        customer_changeset =
          Case
          |> Ash.Changeset.for_create(:create, case_attr |> Map.put(:team_id, customer_team.id))

        assert {:ok, _case} = mssp_changeset |> Ash.create()
        assert {:error, _case} = customer_changeset |> Ash.create()
        assert {:error, _case} = nil_changeset |> Ash.create()
      end
    end
  end

  describe "negative tests for creating cases" do
  end

  describe "positive tests for relationships" do
  end

  describe "negative tests for relationships" do
  end
end
