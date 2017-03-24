defmodule EmberWeekendApi.FeedView do
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
    case model.show_notes do
      %Ecto.Association.NotLoaded{} ->
        model
        |> Ecto.assoc(:show_notes)
        |> EmberWeekendApi.Repo.all
      other -> other
    end
  end

  def guests(model) do
    case model.guests do
      %Ecto.Association.NotLoaded{} ->
        model
        |> Ecto.assoc(:guests)
        |> EmberWeekendApi.Repo.all
      other -> other
    end
  end

  def resource(model) do
    case model.resource do
      %Ecto.Association.NotLoaded{} ->
        model
        |> Ecto.assoc(:resource)
        |> EmberWeekendApi.Repo.one
      other -> other
    end
  end

  def episode_url(model) do
    "https://emberweekend.com/episodes/#{model.slug}"
  end
end
