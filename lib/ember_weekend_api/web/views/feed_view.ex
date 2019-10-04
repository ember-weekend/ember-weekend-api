defmodule EmberWeekendApi.Web.FeedView do
  use EmberWeekendApi.Web, :view

  def episodes(conn) do
    conn.assigns.episodes
  end

  defp rfc_2822_date(date) do
    Timex.Format.DateTime.Formatter.format(date, "%a, %d %b %Y %H:%M:%S EST", :strftime)
  end

  def release_date(episode) do
    {:ok, date} = episode.release_date |> rfc_2822_date
    date
  end

  def pub_date(episodes) do
    case episodes do
      [most_recent | _] -> episodes
        release_date(most_recent)
      [] -> nil
    end
  end

  def last_build_date(episodes) do
    case episodes do
      [most_recent | _] -> Enum.sort(episodes, &(DateTime.compare(&1.updated_at, &2.updated_at)))
        {:ok, date} = rfc_2822_date(most_recent.updated_at)
        date
      [] -> nil
    end
  end

  def show_notes(episode) do
    case episode.show_notes do
      nil -> []
      show_notes -> Enum.sort(show_notes, &(&1.time_stamp < &2.time_stamp))
    end
  end

  def guests(episode) do
    episode.guests
  end

  def resource(show_note) do
    show_note.resource
  end

  def show_note_title(show_note) do
    case show_note.resource do
      nil -> show_note.note
      resource -> resource.title
    end
  end

  def episode_url(episode) do
    "https://emberweekend.com/episodes/#{episode.slug}"
  end

  def escape(str) do
    {:safe, safe} = Phoenix.HTML.html_escape(str)
    safe
  end

  def resource_url(show_note) do
    case resource(show_note) do
      nil -> nil
      resource -> case resource.url do
        nil -> nil
        "" -> nil
        not_blank -> not_blank
      end
    end
  end
end
