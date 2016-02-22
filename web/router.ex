defmodule EmberWeekendApi.Router do
  use EmberWeekendApi.Web, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", EmberWeekendApi do
    pipe_through :api

    resources "/episodes", EpisodeController, only: [:index, :show]
  end
end
