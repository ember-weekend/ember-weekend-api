defmodule EmberWeekendApi.EpisodeController do
  use EmberWeekendApi.Web, :controller
  import EmberWeekendApi.Auth
  import EmberWeekendApi.ControllerErrors
  alias EmberWeekendApi.Episode
  alias EmberWeekendApi.EpisodeGuest

  plug :model_name, :episode
  plug :authenticate, :admin when action in [:create, :update, :delete]

  def index(conn, _params) do
    episodes = Repo.all(Episode)
    render(conn, data: episodes)
  end

  def show(conn, %{"id" => id}) do
    case find_by_slug_or_id(id) do
      nil -> not_found(conn)
      episode -> render(conn, data: episode, opts: [
        include: "show_notes,guests"
      ])
    end
  end

  defp find_by_slug_or_id(id) do
    case Integer.parse(id) do
      :error -> Repo.get_by(Episode, %{slug: id})
      {id,_} -> Repo.get(Episode, id)
    end
  end

  defp extract_relationship_ids(relationships, name) do
    Enum.map(relationships[name]["data"], fn(a) ->
      Integer.parse(a["id"])
      |> elem(0)
    end)
  end

  def create(conn, %{"data" => %{ "relationships" => relationships, "attributes" => attributes}}) do
    changeset = Episode.changeset(%Episode{}, attributes)
    case Repo.insert(changeset) do
      {:ok, episode} ->
        guest_ids = extract_relationship_ids(relationships, "guests")
        Enum.each guest_ids, fn(id) ->
          attributes = %{episode_id: episode.id, guest_id: id}
          changeset = EpisodeGuest.changeset(%EpisodeGuest{}, attributes)
          Repo.insert(changeset)
        end
        conn
        |> put_status(:created)
        |> render(:show, data: episode)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(:errors, data: changeset)
    end
  end
  def create(conn, %{"data" => %{"attributes" => attributes}}) do
    create conn, %{"data" => %{ "relationships" => [], "attributes" => attributes}}
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
