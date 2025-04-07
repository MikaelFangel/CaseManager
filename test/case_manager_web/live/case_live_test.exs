defmodule CaseManagerWeb.CaseLiveTest do
  use CaseManagerWeb.ConnCase

  import Phoenix.LiveViewTest
  import CaseManager.IncidentsFixtures

  @create_attrs %{title: "some title"}
  @update_attrs %{title: "some updated title"}
  @invalid_attrs %{title: nil}
  defp create_case(_) do
    case = case_fixture()

    %{case: case}
  end

  describe "Index" do
    setup [:create_case]

    test "lists all cases", %{conn: conn, case: case} do
      {:ok, _index_live, html} = live(conn, ~p"/cases")

      assert html =~ "Listing Cases"
      assert html =~ case.title
    end

    test "saves new case", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/cases")

      assert {:ok, form_live, _} =
               index_live
               |> element("a", "New Case")
               |> render_click()
               |> follow_redirect(conn, ~p"/cases/new")

      assert render(form_live) =~ "New Case"

      assert form_live
             |> form("#case-form", case: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#case-form", case: @create_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/cases")

      html = render(index_live)
      assert html =~ "Case created successfully"
      assert html =~ "some title"
    end

    test "updates case in listing", %{conn: conn, case: case} do
      {:ok, index_live, _html} = live(conn, ~p"/cases")

      assert {:ok, form_live, _html} =
               index_live
               |> element("#cases-#{case.id} a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/cases/#{case}/edit")

      assert render(form_live) =~ "Edit Case"

      assert form_live
             |> form("#case-form", case: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#case-form", case: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/cases")

      html = render(index_live)
      assert html =~ "Case updated successfully"
      assert html =~ "some updated title"
    end

    test "deletes case in listing", %{conn: conn, case: case} do
      {:ok, index_live, _html} = live(conn, ~p"/cases")

      assert index_live |> element("#cases-#{case.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#cases-#{case.id}")
    end
  end

  describe "Show" do
    setup [:create_case]

    test "displays case", %{conn: conn, case: case} do
      {:ok, _show_live, html} = live(conn, ~p"/cases/#{case}")

      assert html =~ "Show Case"
      assert html =~ case.title
    end

    test "updates case and returns to show", %{conn: conn, case: case} do
      {:ok, show_live, _html} = live(conn, ~p"/cases/#{case}")

      assert {:ok, form_live, _} =
               show_live
               |> element("a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/cases/#{case}/edit?return_to=show")

      assert render(form_live) =~ "Edit Case"

      assert form_live
             |> form("#case-form", case: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, show_live, _html} =
               form_live
               |> form("#case-form", case: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/cases/#{case}")

      html = render(show_live)
      assert html =~ "Case updated successfully"
      assert html =~ "some updated title"
    end
  end
end
