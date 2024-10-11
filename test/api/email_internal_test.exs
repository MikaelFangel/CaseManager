defmodule CaserManager.EmailInternalTest do
  @moduledoc """
  Test cases for the internal api for the email resource.
  """
  use CaseManager.DataCase, async: true
  use ExUnitProperties
  alias CaseManager.ContactInfos.Email

  describe "positive test for emails" do
    property "emails can be created " do
      check all(
              email <- StreamData.string(:alphanumeric, min_length: 1),
              domain <- StreamData.string(:alphanumeric, min_length: 1)
            ) do
        changeset =
          Email
          |> Ash.Changeset.for_create(:create, %{email: email <> "@" <> domain <> ".com"})
          |> Ash.create()

        assert {:ok, _email} = changeset
      end
    end
  end

  describe "negative tests for emails" do
    test "fails to create email entity when the email is nil" do
      changeset =
        Email
        |> Ash.Changeset.for_create(:create, %{email: nil})
        |> Ash.create()

      assert {:error, _email} = changeset
    end
  end
end
