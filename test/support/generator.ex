defmodule CaseManager.Generator do
  @moduledoc false
  use Ash.Generator

  def team(opts \\ []) do
    changeset_generator(
      CaseManager.Teams.Team,
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
      CaseManager.Teams.User,
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
end
