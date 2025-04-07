defmodule CaseManagerWeb.AlertLiveTest do
  use CaseManagerWeb.ConnCase

  import Phoenix.LiveViewTest
  import CaseManager.IncidentsFixtures

  @create_attrs %{title: "some title"}
  @update_attrs %{title: "some updated title"}
  @invalid_attrs %{title: nil}
  defp create_alert(_) do
    alert = alert_fixture()

    %{alert: alert}
  end

  describe "Index" do
    setup [:create_alert]

    test "lists all alert", %{conn: conn, alert: alert} do
      {:ok, _index_live, html} = live(conn, ~p"/alert")

      assert html =~ "Listing Alert"
      assert html =~ alert.title
    end

    test "saves new alert", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/alert")

      assert {:ok, form_live, _} =
               index_live
               |> element("a", "New Alert")
               |> render_click()
               |> follow_redirect(conn, ~p"/alert/new")

      assert render(form_live) =~ "New Alert"

      assert form_live
             |> form("#alert-form", alert: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#alert-form", alert: @create_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/alert")

      html = render(index_live)
      assert html =~ "Alert created successfully"
      assert html =~ "some title"
    end

    test "updates alert in listing", %{conn: conn, alert: alert} do
      {:ok, index_live, _html} = live(conn, ~p"/alert")

      assert {:ok, form_live, _html} =
               index_live
               |> element("#alert-#{alert.id} a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/alert/#{alert}/edit")

      assert render(form_live) =~ "Edit Alert"

      assert form_live
             |> form("#alert-form", alert: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#alert-form", alert: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/alert")

      html = render(index_live)
      assert html =~ "Alert updated successfully"
      assert html =~ "some updated title"
    end

    test "deletes alert in listing", %{conn: conn, alert: alert} do
      {:ok, index_live, _html} = live(conn, ~p"/alert")

      assert index_live |> element("#alert-#{alert.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#alert-#{alert.id}")
    end
  end

  describe "Show" do
    setup [:create_alert]

    test "displays alert", %{conn: conn, alert: alert} do
      {:ok, _show_live, html} = live(conn, ~p"/alert/#{alert}")

      assert html =~ "Show Alert"
      assert html =~ alert.title
    end

    test "updates alert and returns to show", %{conn: conn, alert: alert} do
      {:ok, show_live, _html} = live(conn, ~p"/alert/#{alert}")

      assert {:ok, form_live, _} =
               show_live
               |> element("a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/alert/#{alert}/edit?return_to=show")

      assert render(form_live) =~ "Edit Alert"

      assert form_live
             |> form("#alert-form", alert: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, show_live, _html} =
               form_live
               |> form("#alert-form", alert: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/alert/#{alert}")

      html = render(show_live)
      assert html =~ "Alert updated successfully"
      assert html =~ "some updated title"
    end
  end
end
