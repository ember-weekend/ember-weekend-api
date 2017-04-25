use Mix.Config

# For development, we disable any cache and enable
# debugging and code reloading.
#
# The watchers configuration can be used to run external
# watchers to your application. For example, we use it
# with brunch.io to recompile .js and .css sources.
config :ember_weekend_api, EmberWeekendApi.Web.Endpoint,
  http: [port: 4000],
  debug_errors: true,
  code_reloader: true,
  check_origin: false,
  watchers: []

# Watch static and templates for browser reloading.
config :ember_weekend_api, EmberWeekendApi.Web.Endpoint,
  secret_key_base: "iSFpZGaE90m7xArjQY/hjEBAxC9Wy8NXMYAQQ+OaSKEd4epRi4VJxQXtCxBODwOy",
  live_reload: [
    patterns: [
      ~r{priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$},
      ~r{priv/gettext/.*(po)$},
      ~r{lib/ember_weekend_api/web/views/.*(ex)$},
      ~r{lib/ember_weekend_api/web/templates/.*(eex)$}
    ]
  ]

# Do not include metadata nor timestamps in development logs
config :logger, :console, format: "[$level] $message\n"

# Set a higher stacktrace during development.
# Do not configure such in production as keeping
# and calculating stacktraces is usually expensive.
config :phoenix, :stacktrace_depth, 20

# Configure your database
config :ember_weekend_api, EmberWeekendApi.Repo,
  adapter: Ecto.Adapters.Postgres,
  database: "ember_weekend_api_dev",
  hostname: "localhost",
  username: "postgres",
  password: "postgres",
  pool_size: 10

config :ember_weekend_api, :github_api, EmberWeekendApi.Github.HTTPClient

admins = Map.get(System.get_env(), "ADMINS", "code0100fun, rondale-sc")
          |> String.replace(~r/\s/,"")
          |> String.split(",")

config :ember_weekend_api, :admins, admins

if File.exists?("config/dev.secret.exs") do
  import_config "dev.secret.exs"
end
