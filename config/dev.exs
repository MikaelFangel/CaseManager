import Config

config :ash, :policies, show_policy_breakdowns?: true

config :ash_authentication, debug_authentication_failures?: true

# Configure your database
config :case_manager, CaseManager.Repo,
  # For development, we disable any cache and enable
  # debugging and code reloading.
  #
  # The watchers configuration can be used to run external
  # watchers to your application. For example, we can use it
  # to bundle .js and .css sources.
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "case_manager_dev",
  stacktrace: true,
  show_sensitive_data_on_connection_error: true,
  pool_size: 10

config :case_manager, CaseManagerWeb.Endpoint,
  # Binding to loopback ipv4 address prevents access from other machines.
  # Change to `ip: {0, 0, 0, 0}` to allow access from other machines.
  https: [
    ip: {127, 0, 0, 1},
    port: 4000,
    cipher_suite: :strong,
    certfile: "priv/cert/selfsigned.pem",
    keyfile: "priv/cert/selfsigned_key.pem"
  ],
  force_ssl: [hsts: true, host: "localhost:4000"],
  check_origin: false,
  code_reloader: true,
  debug_errors: true,
  secret_key_base: "AJSPn64qFHbviO4lKQaJFOmGTk+a86Cv95Ns/0tPyoqzGI8nMLV6Yw1j+nFri64T",
  watchers: [
    esbuild: {Esbuild, :install_and_run, [:case_manager, ~w(--sourcemap=inline --watch)]},
    tailwind: {Tailwind, :install_and_run, [:case_manager, ~w(--watch)]}
  ]

# Watch static and templates for browser reloading.
config :case_manager, CaseManagerWeb.Endpoint,
  live_reload: [
    patterns: [
      ~r"priv/static/(?!uploads/).*(js|css|png|jpeg|jpg|gif|svg)$",
      ~r"priv/gettext/.*(po)$",
      ~r"lib/case_manager_web/(controllers|live|components)/.*(ex|heex)$"
    ]
  ]

# Enable dev routes for dashboard and mailbox
config :case_manager, dev_routes: true

# Do not include metadata nor timestamps in development logs
# Run `mix help phx.gen.cert` for more information.
config :logger, :console, format: "[$level] $message\n"

# Initialize plugs at runtime for faster development compilation
# Set a higher stacktrace during development. Avoid configuring such
# in production as building large stacktraces may be expensive.
config :phoenix, :plug_init_mode, :runtime
config :phoenix, :stacktrace_depth, 20

# Include HEEx debug annotations as HTML comments in rendered markup
config :phoenix_live_view, :debug_heex_annotations, true

# Disable swoosh api client as it is only required for production adapters.
config :swoosh, :api_client, false
