defmodule EmberWeekendApi.Router do
  use EmberWeekendApi.Web, :router

  pipeline :api do
    plug :accepts, ["json-api"]
    plug JaSerializer.ContentTypeNegotiation
    plug JaSerializer.Deserializer
    plug EmberWeekendApi.Plugs.Auth
  end

  scope "/api", EmberWeekendApi do
    pipe_through :api

    resources "/episodes", EpisodeController, only: [:index, :show, :update, :delete, :create]
    resources "/people", PersonController, only: [:index, :show, :update, :delete, :create]
    delete "/sessions/:token", SessionController, :delete
    post "/sessions", SessionController, :create
  end
end
