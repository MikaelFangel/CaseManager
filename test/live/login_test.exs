defmodule CaseManager.Live.LoginTest do
  use CaseManagerWeb.ConnCase, async: true

  describe "/" do
    test "loads login screen when not logged in", %{conn: conn} do
      conn
      |> visit("/")
      |> assert_has("button", text: "Sign in")
    end

    test "user can sign in", %{conn: conn} do
      user = generate(user())

      conn
      |> visit("/")
      |> fill_in("Email", with: user.email)
      |> fill_in("Password", with: "password")
      |> submit()
      |> refute_has("button", text: "Sign in")
    end
  end
end
