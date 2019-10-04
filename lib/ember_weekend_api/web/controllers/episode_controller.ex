defmodule EmberWeekendApi.Web.EpisodeController do
  use EmberWeekendApi.Web, :controller
  import EmberWeekendApi.Auth
  import EmberWeekendApi.Web.ControllerErrors
  alias EmberWeekendApi.Web.Episode
  alias EmberWeekendApi.Web.EpisodeGuest
  alias Ecto.Multi
  import Ecto.Query, only: [from: 2]

  plug :model_name, :episode
  plug :authenticate, :admin when action in [:create, :update, :delete]

  def index(conn, _params) do
    query = case admin? conn do
      true -> Episode
         _ -> Episode.published(Episode)
    end
    episodes = Repo.all(query)
    render(conn, data: episodes)
  end

  def show(conn, %{"id" => id}) do
    case find_by_slug_or_id(conn, id) do
      nil -> not_found(conn)
      episode ->
        conn
        |> put_view(EmberWeekendApi.Web.EpisodeShowView)
        |> render(:show, data: episode, opts: [
          include: "show_notes,show_notes.resource,show_notes.resource.authors,guests"
        ])
    end
  end

  defp find_by_slug_or_id(conn, id) do
    query = case admin? conn do
      true -> Episode
         _ -> Episode.published(Episode)
    end
    case Integer.parse(id) do
      :error ->
        from(e in query, where: e.slug == ^id)
        |> Repo.one
      {id,_} ->
        from(e in query, where: e.id == ^id)
        |> Repo.one
    end
  end

  defp extract_relationship_ids(relationships, name) do
    case relationships[name]["data"] do
      nil -> []
      data -> Enum.map(data, fn(a) ->
                Integer.parse(a["id"])
                |> elem(0)
              end)
    end
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
        |> put_view(EmberWeekendApi.Web.EpisodeShowView)
        |> put_status(:created)
        |> render(:show, data: episode, opts: [
          include: "show_notes,show_notes.resource,show_notes.resource.authors,guests"
        ])
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(:errors, data: changeset)
    end
  end
  def create(conn, %{"data" => %{"attributes" => attributes}}) do
    create conn, %{"data" => %{ "relationships" => %{}, "attributes" => attributes}}
  end

  def update(conn, %{"data" => %{ "relationships" => relationships, "attributes" => attributes}, "id" => id}) do
    case Repo.get(Episode, id) do
      nil -> not_found(conn)
      episode ->
        changeset = Episode.changeset(episode, attributes)
        guest_ids = extract_relationship_ids(relationships, "guests")

        multi = Multi.new
        |> Multi.update(:episode, changeset)
        |> Multi.run(:set_episode_guests, fn(_, %{episode: episode}) ->
          set_episode_guests(%{episode: episode, guest_ids: guest_ids })
        end)

        case Repo.transaction(multi) do
          {:ok, result} ->
            conn
            |> put_view(EmberWeekendApi.Web.EpisodeShowView)
            |> render(:show, data: result.episode)
          {:error, _, changeset, %{}} ->
            conn
            |> put_status(:unprocessable_entity)
            |> render(:errors, data: changeset)
        end
    end
  end
  def update(conn, %{"data" => %{"attributes" => attributes}, "id" => id}) do
    update conn, %{"data" => %{ "relationships" => %{}, "attributes" => attributes}, "id" => id}
  end

  def delete(conn, %{"id" => id}) do
    case Repo.get(Episode, id) do
      nil -> not_found(conn)
      episode ->
        Repo.delete!(episode)
        send_resp(conn, :no_content, "")
    end
  end

  defp set_episode_guests(%{episode: episode, guest_ids: guest_ids}) do
    query = from eg in EpisodeGuest,
              where: eg.episode_id == ^episode.id,
              select: eg.guest_id
    existing_guest_ids = Repo.all(query)

    new_episode_guests = guest_ids -- existing_guest_ids
    remove_episode_guests = existing_guest_ids -- guest_ids

    multi = Enum.reduce(new_episode_guests, Multi.new, fn(id, multi) ->
      attributes = %{guest_id: id, episode_id: episode.id}
      changeset = EpisodeGuest.changeset(%EpisodeGuest{}, attributes)
      Multi.insert(multi, id, changeset)
    end)

    query = from eg in EpisodeGuest,
              where: eg.episode_id == ^episode.id and eg.guest_id in ^remove_episode_guests

    multi
    |> Multi.delete_all(:delete_episode_guests, query)
    |> Repo.transaction()
  end
end
