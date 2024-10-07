defmodule CaseManagerWeb.Router do
  use CaseManagerWeb, :router
  use AshAuthentication.Phoenix.Router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {CaseManagerWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :load_from_session
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug :load_from_bearer
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

    #get "/", PageController, :home

    # Standard controller-backed routes
    auth_routes AuthController, CaseManager.Teams.User, path: "/auth"
    sign_out_route AuthController
    reset_route auth_routes_prefix: "/auth"

    live "/register", AuthLive.Index, :register
    live "/sign-in", AuthLive.Index, :sign_in

    ash_authentication_live_session :authentication_required,
      on_mount: {CaseManagerWeb.LiveUserAuth, :live_user_required} do
      live "/", AlertLive.Index, :index
    end
  end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:case_manager, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: CaseManagerWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
