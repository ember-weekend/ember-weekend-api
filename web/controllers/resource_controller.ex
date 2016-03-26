defmodule EmberWeekendApi.ResourceController do
  use EmberWeekendApi.Web, :controller
  import EmberWeekendApi.Auth
  import EmberWeekendApi.ControllerErrors

  alias EmberWeekendApi.Resource
  alias EmberWeekendApi.ResourceAuthor

  plug :model_name, :resource
  plug :authenticate, :admin when action in [:create, :update, :delete]

  def index(conn, _params) do
    resources = Repo.all(Resource)
    render(conn, data: resources)
  end

  def show(conn, %{"id" => id}) do
    case Repo.get(Resource, id) do
      nil -> not_found(conn)
      resource -> render(conn, data: resource)
    end
  end

  defp extract_relationship_ids(relationships, name) do
    Enum.map(relationships[name]["data"], fn(a) ->
      Integer.parse(a["id"])
      |> elem(0)
    end)
  end

  def create(conn, %{"data" => %{ "relationships" => relationships, "attributes" => attributes}}) do
    changeset = Resource.changeset(%Resource{}, attributes)
    case Repo.insert(changeset) do
      {:ok, resource} ->
        author_ids = extract_relationship_ids(relationships, "authors")
        Enum.each author_ids, fn(id) ->
          attributes = %{author_id: id, resource_id: resource.id}
          changeset = ResourceAuthor.changeset(%ResourceAuthor{}, attributes)
          Repo.insert(changeset)
        end
        conn
        |> put_status(:created)
        |> render(:show, data: resource)
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
    case Repo.get(Resource, id) do
      nil -> not_found(conn)
      resource ->
        changeset = Resource.changeset(resource, data["attributes"])
        case Repo.update(changeset) do
          {:ok, resource} -> render(conn, :show, data: resource)
          {:error, changeset} ->
            conn
            |> put_status(:unprocessable_entity)
            |> render(:errors, data: changeset)
        end
    end
  end

  def delete(conn, %{"id" => id}) do
    case Repo.get(Resource, id) do
      nil -> not_found(conn)
      resource ->
        Repo.delete!(resource)
        send_resp(conn, :no_content, "")
    end
  end
end
