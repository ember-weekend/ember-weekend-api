defmodule EmberWeekendApi.ShowNoteView do
  use EmberWeekendApi.Web, :view
  use JaSerializer.PhoenixView
  alias EmberWeekendApi.ShowNote
  alias EmberWeekendApi.Episode
  alias EmberWeekendApi.Resource
  alias EmberWeekendApi.ResourceView
  alias EmberWeekendApi.EpisodeView

  location "/api/show_notes/:id"
  attributes [:time_stamp]

  has_one :resource,
    type: "resources",
    serializer: ResourceView,
    include: false

  has_one :episode,
    type: "episodes",
    serializer: EpisodeView,
    include: false

  def type, do: "show-notes"

  def resource(model, _conn) do
    case model.resource do
      %Ecto.Association.NotLoaded{} ->
        model
        |> Ecto.Model.assoc(:resource)
        |> EmberWeekendApi.Repo.one
      other -> other
    end
  end

  def episode(model, _conn) do
    case model.episode do
      %Ecto.Association.NotLoaded{} ->
        model
        |> Ecto.Model.assoc(:episode)
        |> EmberWeekendApi.Repo.one
      other -> other
    end
  end

end
