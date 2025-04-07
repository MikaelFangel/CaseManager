[
  import_deps: [:phoenix, :ash_json_api, :ash_authentication, :ash_authentication_phoenix, :ash, :ash_archival],
  inputs: ["*.{heex,ex,exs}", "{config,lib,test}/**/*.{heex,ex,exs}", "priv/*/seeds.exs"],
  plugins: [Styler, Phoenix.LiveView.HTMLFormatter, Spark.Formatter],
  line_length: 120,
  heex_line_length: 300
]
