use Mix.Config

config :ember_weekend_api, EmberWeekendApi.Web.Endpoint,
  http: [port: {:system, "PORT"}],
  url: [scheme: "https", host: "ember-weekend-api.herokuapp.com", port: 443],
  force_ssl: [rewrite_on: [:x_forwarded_proto]],
  secret_key_base: Map.fetch!(System.get_env(), "SECRET_KEY_BASE")

config :ember_weekend_api, EmberWeekendApi.Repo,
  adapter: Ecto.Adapters.Postgres,
  url: Map.fetch!(System.get_env(), "DATABASE_URL"),
  pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10"),
  ssl: true

config :logger, level: :info

config :ember_weekend_api, :github_api, EmberWeekendApi.Github.HTTPClient

admins = Map.fetch!(System.get_env(), "ADMINS")
          |> String.replace(~r/\s/,"")
          |> String.split(",")

config :ember_weekend_api, :admins, admins

config :ember_weekend_api,
  EmberWeekendApi.Github,
    client_id: Map.fetch!(System.get_env(), "GITHUB_CLIENT_ID"),
    client_secret: Map.fetch!(System.get_env(), "GITHUB_CLIENT_SECRET"),
    redirect_uri: Map.fetch!(System.get_env(), "GITHUB_REDIRECT_URI")

