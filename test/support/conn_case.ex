defmodule CaseManagerWeb.ConnCase do
  @moduledoc """
  This module defines the test case to be used by
  tests that require setting up a connection.

  Such tests rely on `Phoenix.ConnTest` and also
  import other functionality to make it easier
  to build common data structures and query the data layer.

  Finally, if the test case interacts with the database,
  we enable the SQL sandbox, so changes done to the database
  are reverted at the end of every test. If you are using
  PostgreSQL, you can even run database tests asynchronously
  by setting `use CaseManagerWeb.ConnCase, async: true`, although
  this option is not recommended for other databases.
  """

  use ExUnit.CaseTemplate

  alias AshAuthentication.Plug.Helpers
  alias CaseManager.Generator

  using do
    quote do
      use CaseManagerWeb, :verified_routes

      # Import conveniences for testing with connections
      import CaseManager.Generator
      import CaseManagerWeb.ConnCase
      import Phoenix.ConnTest
      import PhoenixTest
      import Plug.Conn

      # The default endpoint for testing
      @endpoint CaseManagerWeb.Endpoint
    end
  end

  setup tags do
    CaseManager.DataCase.setup_sandbox(tags)
    {:ok, conn: Phoenix.ConnTest.build_conn()}
  end

  # source: https://github.com/sevenseacat/tunez/blob/606825d52cdb2e8768d8d35107632a7766a4e827/test/support/conn_case.ex
  def insert_and_authenticate_user(conn, role \\ :admin, team_type \\ :mssp)

  def insert_and_authenticate_user(%{conn: conn}, role, team_type) do
    team_id = Generator.generate(Generator.team(team_type: team_type)).id
    user = Generator.generate(Generator.user(team_id: team_id, role: role))
    %{conn: log_in_user(conn, user), user: user}
  end

  def insert_and_authenticate_user(%Plug.Conn{} = conn, role, team_type) do
    %{conn: conn}
    |> insert_and_authenticate_user(role, team_type)
    |> Map.fetch!(:conn)
  end

  def log_in_user(conn, user) do
    conn
    |> Phoenix.ConnTest.init_test_session(%{})
    |> Helpers.store_in_session(user)
  end
end
