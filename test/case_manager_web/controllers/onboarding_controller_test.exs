defmodule CaseManagerWeb.OnboardingControllerTest do
  use CaseManagerWeb.ConnCase, async: true

  alias CaseManager.AppConfig.Setting

  describe "GET /onboarding" do
    test "redirects when onboarding is enabled", %{conn: conn} do
      Setting.set_setting!("onboarding_completed?", "true")

      conn = get(conn, ~p"/onboarding")
      assert redirected_to(conn) == "/"
    end

    test "does not redirect when onboarding is disabled", %{conn: conn} do
      Setting.set_setting!("onboarding_completed?", "false")

      conn = get(conn, ~p"/onboarding")
      assert html_response(conn, 200) =~ "Get your platform ready"
    end
  end
end
