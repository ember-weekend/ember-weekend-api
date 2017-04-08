defmodule EmberWeekendApi.Web.Endpoint do
  use Phoenix.Endpoint, otp_app: :ember_weekend_api

  socket "/socket", EmberWeekendApi.Web.UserSocket

  # Code reloading can be explicitly enabled under the
  # :code_reloader configuration of your endpoint.
  if code_reloading? do
    socket "/phoenix/live_reload/socket", Phoenix.LiveReloader.Socket
    plug Phoenix.LiveReloader
    plug Phoenix.CodeReloader
  end

  plug Plug.RequestId
  plug Plug.Logger

  plug EmberWeekendApi.Plugs.URLFormat
  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Poison

  plug Plug.MethodOverride
  plug Plug.Head

  plug Plug.Session,
    store: :cookie,
    key: "_ember_weekend_api_key",
    signing_salt: "Z63alZTm"

  plug Corsica, origins: "*", allow_headers: ["accept", "content-type", "authorization"]
  plug EmberWeekendApi.Web.Router
end
