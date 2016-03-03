defmodule EmberWeekendApi.ResourceView do
  use EmberWeekendApi.Web, :view
  use JaSerializer.PhoenixView
  alias EmberWeekendApi.PersonView
  alias EmberWeekendApi.Resource

  location "/api/resources/:id"
  attributes [:title, :url]

  has_many :authors,
    type: "people",
    serializer: PersonView,
    include: false

  def type, do: "resources"

  def authors(model, _conn) do
    case model.authors do
      %Ecto.Association.NotLoaded{} ->
        model
        |> Ecto.Model.assoc(:authors)
        |> EmberWeekendApi.Repo.all
      other -> other
    end
  end
end
