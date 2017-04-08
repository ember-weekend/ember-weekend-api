defmodule EmberWeekendApi.Web.FeedView do
  use EmberWeekendApi.Web, :view

  def episodes(conn) do
    conn.assigns.episodes
  end

  def release_date(episode) do
    {:ok, date} = episode.release_date
      |> Timex.Format.DateTime.Formatter.format("%a, %d %b %Y %H:%M:%S %z", :strftime)
    date
  end

  def show_notes(model) do
    model.show_notes
  end

  def guests(model) do
    model.guests
  end

  def resource(model) do
    model.resource
  end

  def episode_url(model) do
    "https://emberweekend.com/episodes/#{model.slug}"
  end
end
