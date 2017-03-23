defmodule EmberWeekendApi.PersonControllerTest do
  use EmberWeekendApi.ConnCase
  alias EmberWeekendApi.Person

  @invalid_attrs %{}

  setup %{conn: conn} do
    conn = conn
    |> put_req_header("accept", "application/vnd.api+json")
    |> put_req_header("content-type", "application/vnd.api+json")
    {:ok, conn: conn}
  end

  test "lists all people on index", %{conn: conn} do
    attrs = params_for(:person)
    person = struct(Person, attrs) |> Repo.insert!
    conn = get conn, person_path(conn, :index)

    assert conn.status == 200
    assert json_api_response(conn)["data"] == [%{
      "id" => "#{person.id}",
      "type" => "people",
      "relationships" => %{
        "episodes" => %{},
        "resources" => %{},
      },
      "links" => %{"self" => "/api/people/#{person.id}"},
      "attributes" => attrs
                    |> string_keys
                    |> dasherize_keys
    }]
  end

  test "shows person", %{conn: conn} do
    attrs = params_for(:person)
    person = struct(Person, attrs) |> Repo.insert!

    conn = get conn, person_path(conn, :show, person)

    assert conn.status == 200
    assert json_api_response(conn)["data"] == %{
      "id" => "#{person.id}",
      "type" => "people",
      "relationships" => %{
        "episodes" => %{
          "data" => []
        },
        "resources" => %{
          "data" => []
        },
      },
      "links" => %{"self" => "/api/people/#{person.id}"},
      "attributes" => attrs
                    |> string_keys
                    |> dasherize_keys
    }
  end

  test "throws error for invalid person id", %{conn: conn} do
    conn = get conn, person_path(conn, :show, -1)

    assert conn.status == 404
    assert json_api_response(conn)["errors"] == not_found("person")
  end

  test "unauthenticated user can't update person", %{conn: conn} do
    person = insert(:person)
    data = %{data: %{attributes: %{name: "Not secure"}}}

    conn = put conn, person_path(conn, :update, person), data

    assert conn.status == 401
    assert json_api_response(conn)["errors"] == unauthorized("person", "update")
    db_person = Repo.get!(Person, person.id)
    assert db_person.name == person.name
  end

  test "unauthenticated user can't delete person", %{conn: conn} do
    person = insert(:person)

    conn = delete conn, person_path(conn, :update, person)

    assert conn.status == 401
    assert json_api_response(conn)["errors"] == unauthorized("person", "delete")
    person = Repo.get!(Person, person.id)
    assert person
  end

  test "non-admin user can't update person", %{conn: conn} do
    conn = authenticated(conn)
    person = insert(:person)
    data = %{data: %{attributes: %{name: "Not secure"}}}

    conn = put conn, person_path(conn, :update, person), data

    assert conn.status == 401
    assert json_api_response(conn)["errors"] == unauthorized("person", "update")
    db_person = Repo.get!(Person, person.id)
    assert db_person.name == person.name
  end

  test "non-admin user can't delete person", %{conn: conn} do
    conn = authenticated(conn)
    person = insert(:person)

    conn = delete conn, person_path(conn, :update, person)

    assert conn.status == 401
    assert json_api_response(conn)["errors"] == unauthorized("person", "delete")
    person = Repo.get!(Person, person.id)
    assert person
  end

  test "admin user can create person", %{conn: conn} do
    conn = admin(conn)
    attributes = params_for(:person)
      |> dasherize_keys
    data = %{data: %{type: "people", attributes: attributes}}

    conn = post conn, person_path(conn, :create), data

    assert conn.status == 201
    person_id = String.to_integer json_api_response(conn)["data"]["id"]
    assert json_api_response(conn)["data"] == %{
      "id" => "#{person_id}",
      "type" => "people",
      "relationships" => %{
        "episodes" => %{},
        "resources" => %{},
      },
      "links" => %{"self" => "/api/people/#{person_id}"},
      "attributes" => string_keys(attributes)
    }
    assert Person.count == 1
    assert Repo.get!(Person, person_id)
  end

  test "admin user can update person", %{conn: conn} do
    conn = admin(conn)
    person = insert(:person)
    attributes = %{name: "Better Name"}
    data = %{data: %{id: "#{person.id}", type: "people", attributes: attributes}}

    conn = put conn, person_path(conn, :update, person), data

    assert conn.status == 200
    assert json_api_response(conn)["data"]["attributes"]["name"] == "Better Name"
    assert Person.count == 1
    person = Repo.get!(Person, person.id)
    assert person.name == "Better Name"
  end

  test "admin user sees validation messages when creating person", %{conn: conn} do
    conn = admin(conn)
    data = %{data: %{type: "people", attributes: @invalid_attrs}}

    conn = post conn, person_path(conn, :create), data

    assert conn.status == 422
    assert (json_api_response(conn)["errors"] |> sort_by("detail")) == [
      cant_be_blank("name"),
      cant_be_blank("handle"),
      cant_be_blank("avatar_url"),
      cant_be_blank("url")
    ] |> sort_by("detail")
  end

  test "admin user sees validation messages when updating person", %{conn: conn} do
    conn = admin(conn)
    person = insert(:person)
    data = %{data: %{id: "#{person.id}", type: "people", attributes: %{"name" => nil}}}

    conn = put conn, person_path(conn, :update, person), data

    assert conn.status == 422
    assert json_api_response(conn)["errors"] == [
      cant_be_blank("name")
    ]
  end

  test "admin user can delete person", %{conn: conn} do
    conn = admin(conn)
    person = insert(:person)

    conn = delete conn, person_path(conn, :update, person)

    assert conn.status == 204
    assert Person.count() == 0
  end

end
