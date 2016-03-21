use Mix.Config

config :ember_weekend_api, EmberWeekendApi.Endpoint,
  http: [port: {:system, "PORT"}],
  url: [scheme: "https", host: "peaceful-sea-54668.herokuapp.com", port: 443],
  force_ssl: [rewrite_on: [:x_forwarded_proto]],
  cache_static_manifest: "priv/static/manifest.json",
  secret_key_base: System.get_env("SECRET_KEY_BASE")

config :ember_weekend_api, EmberWeekendApi.Repo,
  adapter: Ecto.Adapters.Postgres,
  url: System.get_env("DATABASE_URL"),
  pool_size: 20

config :logger, level: :info

config :ember_weekend_api, :github_api, EmberWeekendApi.Github.HTTPClient
