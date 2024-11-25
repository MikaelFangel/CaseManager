import Config

config :case_manager, CaseManagerWeb.Endpoint, cache_static_manifest: "priv/static/cache_manifest.json"

# Runtime production configuration, including reading
# of environment variables, is done on config/runtime.exs.
config :case_manager, CaseManagerWeb.Endpoint,
  url: [host: "127.0.0.1"],
  check_origin: ["//localhost", "//127.0.0.1"]

# Do not print debug messages in production
config :logger, level: :info

# Configures Swoosh API Client
config :swoosh, api_client: Swoosh.ApiClient.Finch, finch_name: CaseManager.Finch

# Disable Swoosh Local Memory Storage
config :swoosh, local: false
