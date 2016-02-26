defmodule EmberWeekendApi.UserView do
  use EmberWeekendApi.Web, :view
  use JaSerializer.PhoenixView
  attributes [:name, :username]
end
