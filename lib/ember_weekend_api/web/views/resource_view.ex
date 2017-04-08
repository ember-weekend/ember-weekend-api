defmodule EmberWeekendApi.Web.ResourceView do
  use EmberWeekendApi.Web, :view
  use JaSerializer.PhoenixView
  alias EmberWeekendApi.Web.PersonView
  alias EmberWeekendApi.Web.ShowNoteView

  location "/api/resources/:id"
  attributes [:title, :url]

  has_many :authors,
    type: "people",
    serializer: PersonView,
    include: false

  has_many :show_notes,
    type: "show-notes",
    serializer: ShowNoteView,
    include: false

  def type, do: "resources"

  def authors(model, _conn) do
    case model.authors do
      %Ecto.Association.NotLoaded{} ->
        model
        |> Ecto.assoc(:authors)
        |> EmberWeekendApi.Repo.all
      other -> other
    end
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
end
