import Config

config :bcrypt_elixir, log_rounds: 1

# Configure your database

# In test we don't send emails
#
# to provide built-in test partitioning in CI environment.
# The MIX_TEST_PARTITION environment variable can be used

# Run `mix help test` for more information.
config :case_manager, CaseManager.Mailer, adapter: Swoosh.Adapters.Test

config :case_manager, CaseManager.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "case_manager_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  # We don't run a server during test. If one is required,
  # you can enable the server option below.
  pool_size: System.schedulers_online() * 2

config :case_manager, CaseManagerWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "sySOWHRNwhgR61W7Hy8cVtmjfxuhsgO/bRM7NZAvyAOG2r098b9pe5qFQH04QNjJ",
  server: false

config :case_manager, token_signing_secret: "pY/1Bcs0rI0FaZF+vgA9JWZ7BWzCEsGS"

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

# Enable helpful, but potentially expensive runtime checks
config :phoenix_live_view,
  enable_expensive_runtime_checks: true

# Disable swoosh api client as it is only required for production adapters
config :swoosh, :api_client, false
