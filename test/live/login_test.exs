defmodule CaseManager.Live.LoginTest do
  use CaseManagerWeb.ConnCase, async: true

  @public_routes [
    "/sign-in",
    "/onboarding",
    "/onboarding/team",
    "/onboarding/user"
  ]

  @protected_routes [
    "/users",
    "/alerts",
    "/case/new",
    "/teams",
    "/settings",
    "/user"
  ]

  describe "public routes" do
    test "user can sign in", %{conn: conn} do
      user = generate(user())

      conn
      |> visit("/")
      |> fill_in("Email", with: user.email)
      |> fill_in("Password", with: "password")
      |> submit()
      |> refute_has("button", text: "Sign in")
    end

    for route <- @public_routes do
      @route route
      test "GET #{@route} public pages doesn't redirect", %{conn: conn} do
        conn
        |> visit(@route)
        |> assert_path(@route)
      end
    end
  end

  describe "protected routes" do
    for route <- @protected_routes do
      @route route
      test "GET #{@route} redirects to login when not authenticated", %{conn: conn} do
        conn
        |> visit(@route)
        |> assert_has("button", text: "Sign in")
      end
    end
  end
end
