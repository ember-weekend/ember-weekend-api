use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :ember_weekend_api, EmberWeekendApi.Web.Endpoint,
  secret_key_base: "iSFpZGaE90m7xArjQY/hjEBAxC9Wy8NXMYAQQ+OaSKEd4epRi4VJxQXtCxBODwOy",
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
if Map.has_key?(System.get_env(), "DATABASE_URL") do
  config :ember_weekend_api, EmberWeekendApi.Repo,
    adapter: Ecto.Adapters.Postgres,
    url: System.get_env("DATABASE_URL"),
    pool: Ecto.Adapters.SQL.Sandbox
else
  config :ember_weekend_api, EmberWeekendApi.Repo,
    adapter: Ecto.Adapters.Postgres,
    database: "ember_weekend_api_test",
    hostname: "localhost",
    username: "postgres",
    password: "postgres",
    pool: Ecto.Adapters.SQL.Sandbox
end

config :ember_weekend_api, :github_api, EmberWeekendApi.Github.Stub
config :ember_weekend_api, :admins, ["tinyrick"]
