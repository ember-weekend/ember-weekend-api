defmodule EmberWeekendApi.SessionView do
  use EmberWeekendApi.Web, :view
  use JaSerializer.PhoenixView
  alias EmberWeekendApi.UserView
  alias EmberWeekendApi.User
  def type, do: "sessions"
  attributes [:token]

  has_one :user,
    field: :user,
    type: "users",
    serializer: UserView,
    include: true

  def user(model, conn) do
    case model.user do
      %Ecto.Association.NotLoaded{} ->
        model
        |> Ecto.Model.assoc(:user)
        |> EmberWeekendApi.Repo.all
      other -> other
    end
  end
end
