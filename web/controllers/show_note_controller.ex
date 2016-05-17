defmodule EmberWeekendApi.ShowNoteController do
  use EmberWeekendApi.Web, :controller
  import EmberWeekendApi.Auth
  import EmberWeekendApi.ControllerErrors

  alias EmberWeekendApi.ShowNote
  alias EmberWeekendApi.Repo
  alias EmberWeekendApi.Episode
  alias EmberWeekendApi.Resource

  plug :model_name, :show_note
  plug :authenticate, :admin when action in [:create, :update, :delete]

  def index(conn, _params) do
    show_notes = Repo.all(ShowNote)
    render(conn, data: show_notes, opts: [include: "resource,resource.authors"])
  end

  def create(conn, %{"data" => %{ "relationships" => relationships, "attributes" => attributes}}) do
    {episode_id,_} = Integer.parse(relationships["episode"]["data"]["id"])
    {resource_id,_} = Integer.parse(relationships["resource"]["data"]["id"])
    attributes = Map.merge(attributes, %{
      "resource_id" => resource_id,
      "episode_id" => episode_id
    })
    changeset = ShowNote.changeset(%ShowNote{}, attributes)
    case Repo.insert(changeset) do
      {:ok, show_note} ->
        conn
        |> put_status(:created)
        |> render(:show, data: show_note)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(:errors, data: changeset)
    end
  end

  def update(conn, %{"data" => data, "id" => id}) do
    case Repo.get(ShowNote, id) do
      nil -> not_found(conn)
      show_note ->
        changeset = ShowNote.changeset(show_note, data["attributes"])
        case Repo.update(changeset) do
          {:ok, show_note} -> render(conn, :show, data: show_note)
          {:error, changeset} ->
            conn
            |> put_status(:unprocessable_entity)
            |> render(:errors, data: changeset)
        end
    end
  end
end
