defmodule EmberWeekendApi.PersonView do
  use EmberWeekendApi.Web, :view
  use JaSerializer.PhoenixView
  alias EmberWeekendApi.Person

  location "/api/people/:id"
  attributes [:name, :handle, :url, :avatar_url]

  def type, do: "people"

  def id(%Person{id: id}, _conn), do: id

end
