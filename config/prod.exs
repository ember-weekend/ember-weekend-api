use Mix.Config

config :ember_weekend_api, EmberWeekendApi.Endpoint,
  http: [port: {:system, "PORT"}],
  url: [scheme: "https", host: "ember-weekend-api.herokuapp.com", port: 443],
  force_ssl: [rewrite_on: [:x_forwarded_proto]],
  secret_key_base: System.get_env("SECRET_KEY_BASE")

config :ember_weekend_api, EmberWeekendApi.Repo,
  adapter: Ecto.Adapters.Postgres,
  url: System.get_env("DATABASE_URL"),
  pool_size: 20

config :logger, level: :info

config :ember_weekend_api, :github_api, EmberWeekendApi.Github.HTTPClient

admins = System.get_env("ADMINS")
          |> (fn
            admins when is_binary(admins) -> admins
            _ -> raise "Must define ADMINS on ENV" end).()
          |> String.replace(~r/\s/,"")
          |> String.split(",")

config :ember_weekend_api, :admins, admins
