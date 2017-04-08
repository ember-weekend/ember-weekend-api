defmodule EmberWeekendApi.Web.UserView do
  use EmberWeekendApi.Web, :view
  use JaSerializer.PhoenixView
  attributes [:name, :username]
  def type, do: "users"
end
