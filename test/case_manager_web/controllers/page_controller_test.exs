defmodule CaseManagerWeb.PageControllerTest do
  use CaseManagerWeb.ConnCase, async: true

  test "GET /", %{conn: conn} do
    conn = get(conn, ~p"/")
    assert html_response(conn, 302) =~ "/sign-in"
  end
end
