defmodule EmberWeekendApi.EpisodeView do
  use EmberWeekendApi.Web, :view
  use JaSerializer.PhoenixView
  attributes [:title, :description, :slug, :release_date, :filename, :duration]

  def release_date(episode, _conn) do
    {:ok, date} = Timex.DateFormat.format(episode.release_date, "{YYYY}-{M}-{D}")
    date
  end
end
