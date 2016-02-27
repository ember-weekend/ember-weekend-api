defmodule EmberWeekendApi.EpisodeController do
  use EmberWeekendApi.Web, :controller

  alias EmberWeekendApi.Episode
  alias EmberWeekendApi.Auth

  plug :authenticate, :admin when action in [:create, :update, :delete]

  def index(conn, _params) do
    episodes = Repo.all(Episode)
    render(conn, data: episodes)
  end

  def show(conn, %{"id" => id}) do
    case Repo.get(Episode, id) do
      nil -> not_found(conn)
      episode -> render(conn, data: episode)
    end
  end

  def create(conn, %{"data" => data}) do
    changeset = Episode.changeset(%Episode{}, data["attributes"])
    case Repo.insert(changeset) do
      {:ok, episode} ->
        conn
        |> put_status(:created)
        |> render(:show, data: episode)
      {:error, changeset} -> render(conn, :errors, data: changeset)
    end
  end

  def update(conn, %{"data" => data, "id" => id}) do
    case Repo.get(Episode, id) do
      nil -> not_found(conn)
      episode ->
        changeset = Episode.changeset(episode, data["attributes"])
        case Repo.update(changeset) do
          {:ok, episode} -> render(conn, :show, data: episode)
          {:error, changeset} -> render(conn, :errors, data: changeset)
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

  defp authenticate(conn, :admin) do
    if Auth.admin?(conn) do
      conn
    else
      unauthorized(conn)
    end
  end

  defp not_found(conn) do
    conn
    |> put_status(:not_found)
    |> render(:errors, data: %{
      source: %{ pointer: "/id" },
      status: 404,
      title: "Not found",
      detail: "No episode found for the given id"
    })
    |> halt()
  end

  defp unauthorized(conn) do
    action = Atom.to_string action_name(conn)
    conn
    |> put_status(:unauthorized)
    |> render(:errors, data: %{
      status: 401,
      source: %{ pointer: "/token" },
      title: "Unauthorized",
      detail: "Must provide auth token to #{action} an episode"
    })
    |> halt()
  end

end
