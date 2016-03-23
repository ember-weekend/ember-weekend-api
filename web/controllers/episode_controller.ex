defmodule EmberWeekendApi.EpisodeController do
  use EmberWeekendApi.Web, :controller
  import EmberWeekendApi.Auth
  import EmberWeekendApi.ControllerErrors
  alias EmberWeekendApi.Episode

  plug :model_name, :episode
  plug :authenticate, :admin when action in [:create, :update, :delete]

  def index(conn, _params) do
    episodes = Repo.all(Episode)
    render(conn, data: episodes)
  end

  def show(conn, %{"id" => id}) do
    case Repo.get(Episode, id) do
      nil -> not_found(conn)
      episode -> render(conn, data: episode, opts: [include: "show_notes"])
    end
  end

  def create(conn, %{"data" => data}) do
    changeset = Episode.changeset(%Episode{}, data["attributes"])
    case Repo.insert(changeset) do
      {:ok, episode} ->
        conn
        |> put_status(:created)
        |> render(:show, data: episode)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(:errors, data: changeset)
    end
  end

  def update(conn, %{"data" => data, "id" => id}) do
    case Repo.get(Episode, id) do
      nil -> not_found(conn)
      episode ->
        changeset = Episode.changeset(episode, data["attributes"])
        case Repo.update(changeset) do
          {:ok, episode} -> render(conn, :show, data: episode)
          {:error, changeset} ->
            conn
            |> put_status(:unprocessable_entity)
            |> render(:errors, data: changeset)
        end
    end
  end

  def delete(conn, %{"id" => id}) do
    case Repo.get(Episode, id) do
      nil -> not_found(conn)
      episode ->
        Repo.delete!(episode)
        send_resp(conn, :no_content, "")
    end
  end

end
