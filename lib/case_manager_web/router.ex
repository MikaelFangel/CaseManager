defmodule CaseManagerWeb.Router do
  use CaseManagerWeb, :router
  use AshAuthentication.Phoenix.Router

  pipeline :browser do
    plug :accepts, ["html"]

    if Mix.env() != :test do
      plug Plug.SSL, rewrite_on: [:x_forwarded_proto]
    end

    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {CaseManagerWeb.Layouts, :root}
    plug :protect_from_forgery

    if Mix.env() == :prod do
      plug :put_secure_browser_headers, %{
        "content-security-policy" =>
          "default-src 'self'; img-src 'self' data: https:; style-src 'self' 'unsafe-inline' https:;"
      }
    else
      plug :put_secure_browser_headers, %{
        "content-security-policy" =>
          "default-src 'self'; img-src 'self' data: https:; style-src 'self' 'unsafe-inline' https:; script-src 'self' https://cdnjs.cloudflare.com 'nonce-ash_admin-Ed55GFnX';"
      }
    end

    plug :load_from_session
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug :load_from_bearer
  end

  pipeline :onboarding do
    plug CaseManagerWeb.Plugs.Onboarding
  end

  scope "/api/json" do
    pipe_through [:api]

    forward "/swaggerui",
            OpenApiSpex.Plug.SwaggerUI,
            path: "/api/json/open_api",
            default_model_expand_depth: 4

    forward "/", CaseManagerWeb.AshJsonApiRouter
  end

  scope "/", CaseManagerWeb do
    pipe_through :browser

    # Standard controller-backed routes
    auth_routes AuthController, CaseManager.Teams.User, path: "/auth"
    sign_out_route AuthController
    reset_route auth_routes_prefix: "/auth"

    live "/register", AuthLive.Index, :register
    live "/sign-in", AuthLive.Index, :sign_in

    ash_authentication_live_session :admin_user_required,
      on_mount: {CaseManagerWeb.LiveUserAuth, :live_admin_user} do
      live "/users", UsersLive.Index, :index
    end

    ash_authentication_live_session :mssp_team_members_required,
      on_mount: {CaseManagerWeb.LiveUserAuth, :live_mssp_user} do
      live "/alerts", AlertLive.Index, :index
      live "/case/new", CaseLive.New, :new
      live "/case/:id/edit", CaseLive.Edit, :edit
    end

    ash_authentication_live_session :admin_user_and_mssp_team_members_required,
      on_mount: {CaseManagerWeb.LiveUserAuth, :live_admin_mssp_user} do
      live "/teams", TeamLive.Index, :index
      live "/settings", SettingsLive.Index, :index
    end

    ash_authentication_live_session :authentication_required,
      on_mount: {CaseManagerWeb.LiveUserAuth, :live_user_required} do
      live "/", CaseLive.Index, :index
      live "/case/:id", CaseLive.Show, :show
      live "/user", UserLive.Index, :index
      get "/file/:id", FileController, :download
    end
  end

  scope "/onboarding", CaseManagerWeb do
    pipe_through [:browser, :onboarding]

    get "/", OnboardingController, :index
    live "/team", OnboardingLive.NewTeam, :new_team
    live "/user", OnboardingLive.NewAdminUser, :new_admin_user
  end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:case_manager, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import AshAdmin.Router
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      ash_admin("/admin")
      live_dashboard "/dashboard", metrics: CaseManagerWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
