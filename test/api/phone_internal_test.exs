defmodule CaserManager.PhoneInternalTest do
  @moduledoc """
  Test cases for the internal api for the phone resource.
  """
  use CaseManager.DataCase, async: true
  use ExUnitProperties
  alias CaseManager.ContactInfos.Phone

  describe "positive test for phone numbers" do
    property "phone numbers with a numeric value can be created " do
      check all(phone_number <- StreamData.string(?0..?9, min_length: 1)) do
        changeset =
          Phone
          |> Ash.Changeset.for_create(:create, %{phone: phone_number})
          |> Ash.create()

        assert {:ok, _phone} = changeset
      end
    end
  end

  describe "negative tests for phone numbers" do
    test "fails to create phone entity when the number is nil" do
      changeset =
        Phone
        |> Ash.Changeset.for_create(:create, %{phone: nil})
        |> Ash.create()

      assert {:error, _phone} = changeset
    end
  end
end
