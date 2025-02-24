defmodule CaseManager.Generator do
  @moduledoc false
  use Ash.Generator

  alias CaseManager.ICM
  alias CaseManager.ICM.Enums.RiskLevel
  alias CaseManager.ICM.Enums.Status
  alias CaseManager.Teams

  def team(opts \\ []) do
    changeset_generator(
      Teams.Team,
      :create,
      defaults: [
        name: sequence(:team_name, &"team#{&1}"),
        type: StreamData.one_of([:mssp, :customer])
      ],
      overrides: opts
    )
  end

  def user(opts \\ []) do
    team_id =
      opts[:team_id] ||
        once(:default_team_id, fn ->
          generate(team()).id
        end)

    changeset_generator(
      Teams.User,
      :register_with_password,
      defaults: [
        email: sequence(:user_email, &"user#{&1}@example.com"),
        first_name: "John",
        last_name: "Doe",
        password: "password",
        password_confirmation: "password",
        role: StreamData.one_of([:admin, :analyst]),
        team_id: team_id
      ],
      overrides: opts
    )
  end

  def alert(opts \\ []) do
    team_id =
      opts[:team_id] ||
        once(:default_team_id, fn ->
          generate(team()).id
        end)

    changeset_generator(
      ICM.Alert,
      :create,
      defaults: [
        alert_id: StreamData.string(:alphanumeric, length: 8),
        title: StreamData.string(:printable, min_length: 1),
        risk_level: StreamData.one_of(RiskLevel.values()),
        creation_time: DateTime.utc_now() |> DateTime.to_iso8601() |> StreamData.constant(),
        link: StreamData.string(:printable, min_length: 1),
        team_id: team_id
      ],
      overrides: opts
    )
  end

  def case(opts \\ []) do
    team_id =
      opts[:team_id] ||
        once(:default_team_id, fn ->
          generate(team()).id
        end)

    mssp_team_id =
      once(:default_mssp_team_id, fn ->
        generate(team(type: :mssp)).id
      end)

    mssp_user =
      once(:default_user_id, fn ->
        generate(user(team_id: mssp_team_id))
      end)

    changeset_generator(
      ICM.Case,
      :create,
      defaults: [
        title: StreamData.string(:printable, min_length: 1),
        description: StreamData.string(:utf8),
        status: StreamData.one_of(Status.values()),
        priority: StreamData.one_of(RiskLevel.values()),
        escalated: StreamData.boolean(),
        team_id: team_id
      ],
      overrides: opts,
      actor: mssp_user
    )
  end
end
