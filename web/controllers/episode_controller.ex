defmodule EmberWeekendApi.EpisodeController do
  use EmberWeekendApi.Web, :controller
  import EmberWeekendApi.ErrorHandler

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
        |> render_errors([errors: [%{
              status: "404",
              source: %{pointer: "/data/attributes/id"},
              title: "Not Found",
              detail: "No episode found for the given id"}]])
      episode ->
        render(conn, data: episode)
    end
  end

end
