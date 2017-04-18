defmodule EmberWeekendApi.Web.FeedView do
  use EmberWeekendApi.Web, :view

  def episodes(conn) do
    conn.assigns.episodes
  end

  defp rfc_2822_date(date) do
    Timex.Format.DateTime.Formatter.format(date, "%a, %d %b %Y %H:%M:%S %z", :strftime)
  end

  def release_date(episode) do
    {:ok, date} = episode.release_date |> rfc_2822_date
    date
  end

  def pub_date(episodes) do
    [most_recent | _] = episodes
    release_date(most_recent)
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
