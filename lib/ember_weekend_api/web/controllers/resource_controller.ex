defmodule EmberWeekendApi.Web.ResourceController do
  use EmberWeekendApi.Web, :controller
  import EmberWeekendApi.Auth
  import EmberWeekendApi.Web.ControllerErrors
  import Ecto.Query, only: [from: 2]

  alias EmberWeekendApi.Web.Resource
  alias EmberWeekendApi.Web.ResourceAuthor
  alias Ecto.Multi

  plug :model_name, :resource
  plug :authenticate, :admin when action in [:create, :update, :delete]

  def index(conn, _params) do
    resources = Repo.all(from(r in Resource, order_by: [r.title, r.inserted_at]))
    render(conn, data: resources)
  end

  def show(conn, %{"id" => id}) do
    case Repo.get(Resource, id) do
      nil -> not_found(conn)
      resource -> render(conn, data: resource, opts: [
        include: "authors,show_notes"
      ])
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
        |> render(:show, data: resource, opts: [
          include: "authors"
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
    case Repo.get(Resource, id) do
      nil -> not_found(conn)
      resource ->
        changeset = Resource.changeset(resource, attributes)
        author_ids = extract_relationship_ids(relationships, "authors")

        multi = Multi.new
        |> Multi.update(:resource, changeset)
        |> Multi.run(:set_resource_authors, fn(%{resource: resource}) ->
          set_resource_authors(%{resource: resource, author_ids: author_ids })
        end)

        case Repo.transaction(multi) do
          {:ok, result} -> render(conn, :show, data: result.resource)
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
    case Repo.get(Resource, id) do
      nil -> not_found(conn)
      resource ->
        Repo.delete!(resource)
        send_resp(conn, :no_content, "")
    end
  end

  defp set_resource_authors(%{resource: resource, author_ids: author_ids}) do
    query = from ra in ResourceAuthor,
              where: ra.resource_id == ^resource.id,
              select: ra.author_id
    existing_author_ids = Repo.all(query)

    new_resource_authors = author_ids -- existing_author_ids
    remove_resource_authors = existing_author_ids -- author_ids

    multi = Enum.reduce(new_resource_authors, Multi.new, fn(id, multi) ->
      attributes = %{author_id: id, resource_id: resource.id}
      changeset = ResourceAuthor.changeset(%ResourceAuthor{}, attributes)
      Multi.insert(multi, id, changeset)
    end)

    query = from ra in ResourceAuthor,
              where: ra.resource_id == ^resource.id and ra.author_id in ^remove_resource_authors

    multi
    |> Multi.delete_all(:delete_resource_authors, query)
    |> Repo.transaction()
  end
end
