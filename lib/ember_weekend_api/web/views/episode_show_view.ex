defmodule EmberWeekendApi.Web.EpisodeShowView do
  use EmberWeekendApi.Web, :view
  use JaSerializer.PhoenixView
  alias EmberWeekendApi.Web.ShowNoteView
  alias EmberWeekendApi.Web.PersonView

  attributes [
    :number, :title, :description, :slug,
    :release_date, :filename, :duration, :published, :length
  ]

  has_many :show_notes,
    type: "show-notes",
    serializer: ShowNoteView,
    include: false

  has_many :guests,
    type: "people",
    serializer: PersonView,
    include: false

  def type, do: "episodes"

  def release_date(episode, _conn) do
    date = episode.release_date
    Enum.join [date.year, date.month, date.day], "-"
  end

  def show_notes(model, _conn) do
    case model.show_notes do
      %Ecto.Association.NotLoaded{} ->
        model
        |> Ecto.assoc(:show_notes)
        |> EmberWeekendApi.Repo.all
      other -> other
    end
  end

  def guests(model, _conn) do
    case model.guests do
      %Ecto.Association.NotLoaded{} ->
        model
        |> Ecto.assoc(:guests)
        |> EmberWeekendApi.Repo.all
      other -> other
    end
  end
end
