defmodule CaserManager.IpInternalTest do
  @moduledoc """
  Test cases for the internal api for the ip resource.
  """
  use CaseManager.DataCase, async: true
  use ExUnitProperties
  alias CaseManager.ContactInfos.IP

  describe "positive test for ips" do
    property "ips of pseudo ipv4 can be created " do
      check all(
              a <- StreamData.string(?0..?9, min_length: 1, max_length: 3),
              b <- StreamData.string(?0..?9, min_length: 1, max_length: 3),
              c <- StreamData.string(?0..?9, min_length: 1, max_length: 3),
              d <- StreamData.string(?0..?9, min_length: 1, max_length: 3)
            ) do
        changeset =
          IP
          |> Ash.Changeset.for_create(:create, %{
            ip: a <> "." <> b <> "." <> c <> ". " <> d,
            version: :v4
          })
          |> Ash.create()

        assert {:ok, _ip} = changeset
      end
    end
  end

  describe "negative tests ips" do
    test "fails to create ip entity when ip is nil" do
      changeset =
        IP
        |> Ash.Changeset.for_create(:create, %{ip: nil})
        |> Ash.create()

      assert {:error, _ip} = changeset
    end
  end
end
