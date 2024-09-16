[
  import_deps: [:ash_json_api, :ecto, :ecto_sql, :phoenix, :ash, :ash_phoenix, :ash_postgres],
  subdirectories: ["priv/*/migrations"],
  plugins: [Phoenix.LiveView.HTMLFormatter],
  inputs: ["*.{heex,ex,exs}", "{config,lib,test}/**/*.{heex,ex,exs}", "priv/*/seeds.exs"]
]
