defmodule EmberWeekendApi.SessionView do
  use EmberWeekendApi.Web, :view
  use JaSerializer.PhoenixView
  alias EmberWeekendApi.UserView
  attributes [:token]

  has_one :user,
    type: "users",
    serializer: UserView,
    include: false

  def type, do: "sessions"

  def user(model, _conn) do
    case model.user do
      %Ecto.Association.NotLoaded{} ->
        model
        |> Ecto.assoc(:user)
        |> EmberWeekendApi.Repo.one
      other -> other
    end
  end
end
