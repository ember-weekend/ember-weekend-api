defmodule EmberWeekendApi.Web.PersonView do
  use EmberWeekendApi.Web, :view
  use JaSerializer.PhoenixView
  alias EmberWeekendApi.Web.Person
  alias EmberWeekendApi.Web.EpisodeView
  alias EmberWeekendApi.Web.ResourceView

  location "/api/people/:id"
  attributes [:name, :handle, :url, :avatar_url, :tagline, :bio]

  def type, do: "people"

  def id(%Person{id: id}, _conn), do: id

  has_many :episodes,
    type: "episodes",
    serializer: EpisodeView,
    include: false

  has_many :resources,
    type: "resources",
    serializer: ResourceView,
    include: false

  def episodes(model, _conn) do
    case model.episodes do
      %Ecto.Association.NotLoaded{} ->
        model
        |> Ecto.assoc(:episodes)
        |> EmberWeekendApi.Repo.all
      other -> other
    end
  end

  def resources(model, _conn) do
    case model.resources do
      %Ecto.Association.NotLoaded{} ->
        model
        |> Ecto.assoc(:resources)
        |> EmberWeekendApi.Repo.all
      other -> other
    end
  end
end
