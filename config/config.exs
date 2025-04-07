# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :ash,
  allow_forbidden_field_for_relationships_by_default?: true,
  include_embedded_source_by_default?: false,
  show_keysets_for_all_actions?: false,
  default_page_type: :keyset,
  policies: [no_filter_static_forbidden_reads?: false],
  keep_read_action_loads_when_loading?: false,
  default_actions_require_atomic?: true,
  read_action_after_action_hooks_in_order?: true,
  bulk_actions_default_to_errors?: true

config :ash_json_api, show_public_calculations_when_loaded?: false

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :case_manager, CaseManager.Mailer, adapter: Swoosh.Adapters.Local

# Configures the endpoint
config :case_manager, CaseManagerWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [html: CaseManagerWeb.ErrorHTML, json: CaseManagerWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: CaseManager.PubSub,
  live_view: [signing_salt: "xaVnwDuj"]

config :case_manager,
  ecto_repos: [CaseManager.Repo],
  generators: [timestamp_type: :utc_datetime],
  ash_domains: [CaseManager.Accounts]

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.17.11",
  case_manager: [
    args:
      ~w(js/app.js --bundle --target=es2022 --outdir=../priv/static/assets/js --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configures Elixir's Logger
config :logger, :default_formatter,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :mime, extensions: %{"json" => "application/vnd.api+json"}, types: %{"application/vnd.api+json" => ["json"]}

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :spark,
  formatter: [
    remove_parens?: true,
    "Ash.Resource": [
      section_order: [
        :json_api,
        :authentication,
        :tokens,
        :postgres,
        :resource,
        :code_interface,
        :actions,
        :policies,
        :pub_sub,
        :preparations,
        :changes,
        :validations,
        :multitenancy,
        :attributes,
        :relationships,
        :calculations,
        :aggregates,
        :identities
      ]
    ],
    "Ash.Domain": [section_order: [:json_api, :resources, :policies, :authorization, :domain, :execution]]
  ]

# Configure tailwind (the version is required)
config :tailwind,
  version: "4.0.9",
  case_manager: [
    args: ~w(
      --input=assets/css/app.css
      --output=priv/static/assets/css/app.css
    ),

    # Import environment specific config. This must remain at the bottom
    # of this file so it overrides the configuration defined above.
    cd: Path.expand("..", __DIR__)
  ]

import_config "#{config_env()}.exs"
