import Config

# Ensure Ash not spawn tasks to execute requests.
config :ash, :disable_async?, true

# Ignore missed_notifications
config :ash, :missed_notifications, :ignore

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used

# In test we don't send emails.
# to provide built-in test partitioning in CI environment.
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
  secret_key_base: "kXopkd8auxATMLpfF4ju9iggpIg0NX/NKU8niObTpd+UNzze+tZUJzAIR9scWIwa",
  server: false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

# Disable swoosh api client as it is only required for production adapters.
config :swoosh, :api_client, false
