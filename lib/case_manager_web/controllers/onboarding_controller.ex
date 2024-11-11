defmodule CaseManagerWeb.OnboardingController do
  use CaseManagerWeb, :controller

  def index(conn, _params) do
    render(conn, :index, layout: {CaseManagerWeb.Layouts, :onboarding})
  end

  def create_user(conn, _params) do
    render(conn, :create_user, layout: {CaseManagerWeb.Layouts, :onboarding})
  end

  def create_team(conn, _params) do
    render(conn, :create_team, layout: {CaseManagerWeb.Layouts, :onboarding})
  end
end
