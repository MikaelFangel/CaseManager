defmodule CaseManager.Live.CaseTest do
  use CaseManagerWeb.ConnCase, async: true

  describe "Index" do
    test "no cases is present when the platform is started", %{conn: conn} do
      conn
      |> insert_and_authenticate_user()
      |> visit("/")
      |> within("tbody", fn session ->
        refute_has(session, "tr")
      end)
    end

    test "only open cases is shown to the user", %{conn: conn} do
      # open case
      generate(case(status: :in_progress))
      # closed case
      generate(case(status: :f_positive))

      conn
      |> insert_and_authenticate_user()
      |> visit("/")
      |> within("tbody", fn session ->
        assert_has(session, "tr", count: 1)
      end)
    end
  end
end
