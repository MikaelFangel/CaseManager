defmodule CaserManager.EmailInternalTest do
  @moduledoc """
  Test cases for the internal api for the email resource.
  """
  use CaseManager.DataCase, async: true
  use ExUnitProperties
  alias CaseManager.Teams.{Email, Team}

  setup do
    team =
      Team
      |> Ash.Changeset.for_create(:create, %{name: "test", type: :mssp})
      |> Ash.create!()

    %{team: team}
  end

  describe "positive test for emails" do
    property "emails can be created", %{team: team} do
      check all(
              email <- StreamData.string(:alphanumeric, min_length: 1),
              domain <- StreamData.string(:alphanumeric, min_length: 1)
            ) do
        changeset =
          Email
          |> Ash.Changeset.for_create(:create, %{
            team_id: team.id,
            email: email <> "@" <> domain <> ".com"
          })
          |> Ash.create()

        assert {:ok, _email} = changeset
      end
    end
  end

  describe "negative tests for emails" do
    test "fails to create email entity when the email is nil", %{team: team} do
      changeset =
        Email
        |> Ash.Changeset.for_create(:create, %{email: nil, team_id: team.id})
        |> Ash.create()

      assert {:error, _email} = changeset
    end
  end
end
