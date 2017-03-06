defmodule EmberWeekendApi.EpisodeView do
  use EmberWeekendApi.Web, :view
  use JaSerializer.PhoenixView

  attributes [:number, :title, :description, :slug, :release_date, :filename, :duration]

  def type, do: "episodes"

  def release_date(episode, _conn) do
    {:ok, date} = Timex.Date.from(episode.release_date)
      |> Timex.DateFormat.format("%Y-%m-%d", :strftime)
    date
  end

  def show_notes(model, _conn) do
    case model.show_notes do
      %Ecto.Association.NotLoaded{} ->
        model
        |> Ecto.Model.assoc(:show_notes)
        |> EmberWeekendApi.Repo.all
      other -> other
    end
  end

  def guests(model, _conn) do
    case model.guests do
      %Ecto.Association.NotLoaded{} ->
        model
        |> Ecto.Model.assoc(:guests)
        |> EmberWeekendApi.Repo.all
      other -> other
    end
  end
end
