defmodule CaseManagerWeb.Router do
  use CaseManagerWeb, :router
  use AshAuthentication.Phoenix.Router

  import AshAuthentication.Plug.Helpers

  alias AshAuthentication.Phoenix.Overrides.Default

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_live_flash)
    plug(:put_root_layout, html: {CaseManagerWeb.Layouts, :root})
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
    plug(:load_from_session)
  end

  pipeline :api do
    plug(:accepts, ["json"])
    plug(:load_from_bearer)
    plug(:set_actor, :user)
  end

  scope "/api/json" do
    pipe_through([:api])

    forward("/swaggerui", OpenApiSpex.Plug.SwaggerUI, path: "/api/json/open_api", default_model_expand_depth: 4)

    forward("/", CaseManagerWeb.AshJsonApiRouter)
  end

  scope "/", CaseManagerWeb do
    pipe_through(:browser)

    ash_authentication_live_session :authenticated_routes,
      on_mount: {CaseManagerWeb.LiveUserAuth, :live_user_required} do
      # in each liveview, add one of the following at the top of the module:
      #
      # If an authenticated user must be present:
      # on_mount {CaseManagerWeb.LiveUserAuth, :live_user_required}
      #
      # If an authenticated user *may* be present:
      # on_mount {CaseManagerWeb.LiveUserAuth, :live_user_optional}
      #
      # If an authenticated user must *not* be present:
      # on_mount {CaseManagerWeb.LiveUserAuth, :live_no_user}
      live "/alert", AlertLive.Index, :index

      live "/case", CaseLive.Index, :index
      live "/case/new", CaseLive.Form, :new
      live "/case/:id", CaseLive.Show, :show
      live "/case/:id/edit", CaseLive.Form, :edit

      live "/user", UserLive.Index, :index
      live "/user/:id", UserLive.Show, :show

      live "/company", CompanyLive.Index, :index

      live "/soc", SOCLive.Index, :index
    end
  end

  scope "/", CaseManagerWeb do
    pipe_through(:browser)

    get "/", PageController, :home
    auth_routes AuthController, CaseManager.Accounts.User, path: "/auth"
    sign_out_route AuthController

    get "/sign-in", AuthController, :sign_in
  end

  # Other scopes may use custom stacks.
  # scope "/api", CaseManagerWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:case_manager, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through(:browser)

      live_dashboard("/dashboard", metrics: CaseManagerWeb.Telemetry)
      forward("/mailbox", Plug.Swoosh.MailboxPreview)
    end
  end

  if Application.compile_env(:case_manager, :dev_routes) do
    import AshAdmin.Router

    scope "/admin" do
      pipe_through :browser

      ash_admin "/"
    end
  end
end
