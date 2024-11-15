defmodule CaserManager.PhoneInternalTest do
  @moduledoc """
  Test cases for the internal api for the phone resource.
  """
  use CaseManager.DataCase, async: true
  use ExUnitProperties
  alias CaseManager.Teams.{Phone, Team}

  setup do
    team =
      Team
      |> Ash.Changeset.for_create(:create, %{name: "test", type: :mssp})
      |> Ash.create!()

    %{team: team}
  end

  describe "positive test for phone numbers" do
    property "phone numbers with a numeric value can be created", %{team: team} do
      check all(phone_number <- StreamData.string(?0..?9, min_length: 1)) do
        changeset =
          Phone
          |> Ash.Changeset.for_create(:create, %{phone: phone_number, team_id: team.id})
          |> Ash.create()

        assert {:ok, _phone} = changeset
      end
    end
  end

  describe "negative tests for phone numbers" do
    test "fails to create phone entity when the number is nil", %{team: team} do
      changeset =
        Phone
        |> Ash.Changeset.for_create(:create, %{phone: nil, team_id: team.id})
        |> Ash.create()

      assert {:error, _phone} = changeset
    end
  end
end
