defmodule EmberWeekendApi.EpisodeController do
  use EmberWeekendApi.Web, :controller

  alias EmberWeekendApi.Episode

  def index(conn, _params) do
    episodes = Repo.all(Episode)
    render(conn, data: episodes)
  end

  def show(conn, %{"id" => id}) do
    case Repo.get(Episode, id) do
      nil ->
        conn
        |> put_status(:not_found)
        |> render(:errors, data: %{
          source: %{ pointer: "/id" },
          status: 404,
          title: "Not found",
          detail: "No episode found for the given id"
        })
      episode ->
        render(conn, data: episode)
    end
  end

end
