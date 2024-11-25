defmodule CaseManager.TeamInternalTest do
  use CaseManager.DataCase, async: true
  use ExUnitProperties
  alias CaseManager.Teams.Team
  alias CaseManagerWeb.TeamGenerator

  describe "postive tests for creating teams" do
    property "teams with only a name and a type is valid" do
      check all(team_attr <- TeamGenerator.team_attrs()) do
        changeset =
          Team
          |> Ash.Changeset.for_create(:create, team_attr)

        assert {:ok, _team} = Ash.create(changeset)
      end
    end
  end

  describe "negative tests for creating teams" do
    property "fails to create a team without any type or any name" do
      check all(
              team_attr <- TeamGenerator.team_attrs(),
              team_attr_type_nil <-
                StreamData.one_of([
                  StreamData.constant(team_attr |> Map.put(:type, nil)),
                  StreamData.constant(team_attr |> Map.put(:name, nil)),
                  StreamData.constant(team_attr |> Map.put(:type, nil) |> Map.put(:name, nil))
                ])
            ) do
        changeset =
          Team
          |> Ash.Changeset.for_create(:create, team_attr_type_nil)

        assert {:error, _team} = Ash.create(changeset)
      end
    end
  end

  describe "postive relationship test for teams" do
    property "teams can have 0 or more email relationships" do
      check all(
              team_attr <- TeamGenerator.team_attrs(),
              emails <-
                StreamData.list_of(
                  StreamData.map_of(
                    StreamData.constant(:email),
                    StreamData.string(:printable, min_length: 1),
                    length: 1
                  ),
                  length: 1
                )
            ) do
        attrs = Map.merge(team_attr, %{email: emails})

        team =
          CaseManager.Teams.Team
          |> Ash.Changeset.for_create(:create, attrs)
          |> Ash.create!()

        assert length(team.email) === length(emails)
      end
    end

    property "teams can have 0 or more phone relationships" do
      check all(
              team_attr <- TeamGenerator.team_attrs(),
              phone_numbers <-
                StreamData.map_of(
                  StreamData.constant(:phone),
                  StreamData.list_of(
                    StreamData.map_of(
                      StreamData.constant(:phone),
                      StreamData.string(?0..?9, min_length: 5),
                      length: 1
                    )
                  ),
                  length: 1
                )
            ) do
        attrs = Map.merge(team_attr, phone_numbers)

        team =
          CaseManager.Teams.Team
          |> Ash.Changeset.for_create(:create, attrs)
          |> Ash.create!()

        assert length(Ash.load!(team, :phone).phone) === length(phone_numbers.phone)
      end
    end

    property "teams can have 0 or more IP relationships" do
      check all(
              team_attr <- TeamGenerator.team_attrs(),
              ip_list <-
                StreamData.list_of(
                  {StreamData.string(?0..?9, min_length: 5),
                   StreamData.one_of([StreamData.constant(:v4), StreamData.constant(:v6)])}
                )
            ) do
        ips = %{ip: Enum.map(ip_list, fn {ip, version} -> %{ip: ip, version: version} end)}
        attrs = Map.merge(team_attr, ips)

        team =
          CaseManager.Teams.Team
          |> Ash.Changeset.for_create(:create, attrs)
          |> Ash.create!()

        assert length(Ash.load!(team, :ip).ip) === length(ips.ip)
      end
    end
  end
end
