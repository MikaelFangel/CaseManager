import Config

alias Cloak.Ciphers.AES.GCM

config :ash, :pub_sub, debug?: true

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

config :case_manager, CaseManager.Vaults.Alert,
  ciphers: [
    default: {
      GCM,
      # In AES.GCM, it is important to specify 12-byte IV length for
      # interoperability with other encryption software. See this GitHub
      # issue for more details:
      # https://github.com/danielberkompas/cloak/issues/93
      #
      # In Cloak 2.0, this will be the default iv length for AES.GCM.
      tag: "AES.GCM.V1", key: Base.decode64!("aJ7HcM24BcyiwsAvRsa3EG3jcvaFWooyQJ+91OO7bRU="), iv_length: 12
    }
  ]

config :case_manager, CaseManager.Vaults.Case,
  ciphers: [
    default: {
      GCM,
      # In AES.GCM, it is important to specify 12-byte IV length for
      # interoperability with other encryption software. See this GitHub
      # issue for more details:
      # https://github.com/danielberkompas/cloak/issues/93
      #
      # In Cloak 2.0, this will be the default iv length for AES.GCM.
      tag: "AES.GCM.V1", key: Base.decode64!("aJ7HcM24BcyiwsAvRsa3EG3jcvaFWooyQJ+91OO7bRU="), iv_length: 12
    }
  ]

config :case_manager, CaseManager.Vaults.Comment,
  ciphers: [
    default: {
      GCM,
      # In AES.GCM, it is important to specify 12-byte IV length for
      # interoperability with other encryption software. See this GitHub
      # issue for more details:
      # https://github.com/danielberkompas/cloak/issues/93
      #
      # In Cloak 2.0, this will be the default iv length for AES.GCM.
      tag: "AES.GCM.V1", key: Base.decode64!("aJ7HcM24BcyiwsAvRsa3EG3jcvaFWooyQJ+91OO7bRU="), iv_length: 12
    }
  ]

config :case_manager, CaseManagerWeb.Endpoint,
  # Binding to loopback ipv4 address prevents access from other machines.
  # Change to `ip: {0, 0, 0, 0}` to allow access from other machines.
  http: [ip: {127, 0, 0, 1}, port: 4000],
  check_origin: false,
  code_reloader: true,
  debug_errors: true,
  secret_key_base: "HpwHLjCWQMHn7h/sBOl9ZuVibiJ09oHskWHHyYWVVT39e8E9kOq51U44+pBHwlvc",
  watchers: [
    esbuild: {Esbuild, :install_and_run, [:case_manager, ~w(--sourcemap=inline --watch)]},
    tailwind: {Tailwind, :install_and_run, [:case_manager, ~w(--watch)]}
  ]

config :case_manager, CaseManagerWeb.Endpoint,
  https: [
    port: 4001,
    cipher_suite: :strong,
    otp_app: :case_manager,
    keyfile: "priv/cert/selfsigned_key.pem",
    certfile: "priv/cert/selfsigned.pem"
  ]

# Watch static and templates for browser reloading.
config :case_manager, CaseManagerWeb.Endpoint,
  live_reload: [
    web_console_logger: true,
    patterns: [
      ~r"priv/static/(?!uploads/).*(js|css|png|jpeg|jpg|gif|svg)$",
      ~r"priv/gettext/.*(po)$",
      ~r"lib/case_manager_web/(controllers|live|components)/.*(ex|heex)$"
    ]
  ]

# Enable dev routes for dashboard and mailbox
config :case_manager, dev_routes: true, token_signing_secret: "Vq17z/wrHx1CFm4XjoUAhESK86K8LHxL"

# Do not include metadata nor timestamps in development logs
config :logger, :default_formatter, format: "[$level] $message\n"

# Initialize plugs at runtime for faster development compilation
config :phoenix, :plug_init_mode, :runtime

# Set a higher stacktrace during development. Avoid configuring such
# in production as building large stacktraces may be expensive.
config :phoenix, :stacktrace_depth, 20

config :phoenix_live_view,
  # Include HEEx debug annotations as HTML comments in rendered markup.
  # Changing this configuration will require mix clean and a full recompile.
  debug_heex_annotations: true,
  enable_expensive_runtime_checks: true

# Disable swoosh api client as it is only required for production adapters.
config :swoosh, :api_client, false
