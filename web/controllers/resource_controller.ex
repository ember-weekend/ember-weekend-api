defmodule EmberWeekendApi.ResourceController do
  use EmberWeekendApi.Web, :controller
  import EmberWeekendApi.Auth
  import EmberWeekendApi.ControllerErrors

  alias EmberWeekendApi.Resource

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

  def create(conn, %{"data" => data}) do
    changeset = Resource.changeset(%Resource{}, data["attributes"])
    case Repo.insert(changeset) do
      {:ok, resource} ->
        conn
        |> put_status(:created)
        |> render(:show, data: resource)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(:errors, data: changeset)
    end
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
