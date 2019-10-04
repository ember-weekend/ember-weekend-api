defmodule EmberWeekendApi.Repo do
  use Ecto.Repo,
  otp_app: :ember_weekend_api,
  adapter: Ecto.Adapters.Postgres
end
