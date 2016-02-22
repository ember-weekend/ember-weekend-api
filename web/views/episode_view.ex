defmodule EmberWeekendApi.EpisodeView do
  use EmberWeekendApi.Web, :view
  use JaSerializer.PhoenixView
  attributes [:title, :description, :slug, :release_date, :filename, :duration]
end
