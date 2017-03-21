defmodule EmberWeekendApi.PersonController do
  use EmberWeekendApi.Web, :controller
  import EmberWeekendApi.Auth
  import EmberWeekendApi.ControllerErrors
  import Ecto.Query, only: [from: 2]
  alias EmberWeekendApi.Person

  plug :model_name, :person
  plug :authenticate, :admin when action in [:create, :update, :delete]

  def index(conn, _params) do
    people = Repo.all(from(p in Person, order_by: [p.name, p.inserted_at]))
    render(conn, data: people)
  end

  def show(conn, %{"id" => id}) do
    case Repo.get(Person, id) do
      nil -> not_found(conn)
      person ->
        conn
        |> render(:show, data: person, opts: [
          include: "episodes"
        ])
    end
  end

  def create(conn, %{"data" => data}) do
    changeset = Person.changeset(%Person{}, data["attributes"])
    case Repo.insert(changeset) do
      {:ok, person} ->
        conn
        |> put_status(:created)
        |> render(:show, data: person)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(:errors, data: changeset)
    end
  end

  def update(conn, %{"data" => data, "id" => id}) do
    case Repo.get(Person, id) do
      nil -> not_found(conn)
      person ->
        changeset = Person.changeset(person, data["attributes"])
        case Repo.update(changeset) do
          {:ok, person} -> render(conn, :show, data: person)
          {:error, changeset} ->
            conn
            |> put_status(:unprocessable_entity)
            |> render(:errors, data: changeset)
        end
    end
  end

  def delete(conn, %{"id" => id}) do
    case Repo.get(Person, id) do
      nil -> not_found(conn)
      person ->
        Repo.delete!(person)
        send_resp(conn, :no_content, "")
    end
  end
end
