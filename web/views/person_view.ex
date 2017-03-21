defmodule EmberWeekendApi.PersonView do
  use EmberWeekendApi.Web, :view
  use JaSerializer.PhoenixView
  alias EmberWeekendApi.Person
  alias EmberWeekendApi.EpisodeView

  location "/api/people/:id"
  attributes [:name, :handle, :url, :avatar_url, :tagline, :bio]

  def type, do: "people"

  def id(%Person{id: id}, _conn), do: id

  has_many :episodes,
    type: "episodes",
    serializer: EpisodeView,
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
end
