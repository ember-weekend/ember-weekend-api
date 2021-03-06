defmodule EmberWeekendApi.ResourceControllerTest do
  use EmberWeekendApi.Web.ConnCase

  @valid_attrs %{
    title: "Plumbuses",
    url: "http://rickandmorty.wikia.com/wiki/Plumbus"
  }

  @invalid_attrs %{}

  setup %{conn: conn} do
    conn = conn
    |> put_req_header("accept", "application/vnd.api+json")
    |> put_req_header("content-type", "application/vnd.api+json")
    {:ok, conn: conn}
  end

  test "lists all resources on index", %{conn: conn} do
    ra = insert(:resource_author)
    conn = get conn, resource_path(conn, :index)

    assert conn.status == 200
    assert json_api_response(conn)["data"] == [%{
      "relationships" => %{
        "authors" => %{},
        "show-notes" => %{},
      },
      "links" => %{"self" => "/api/resources/#{ra.resource.id}"},
      "id" => "#{ra.resource.id}",
      "type" => "resources",
      "attributes" => @valid_attrs
                    |> string_keys
                    |> dasherize_keys
    }]
  end

  test "shows resource", %{conn: conn} do
    resource = insert(:resource)

    conn = get conn, resource_path(conn, :show, resource)

    assert conn.status == 200
    assert json_api_response(conn)["data"] == %{
      "relationships" => %{
        "authors" => %{
          "data" => []
        },
        "show-notes" => %{
          "data" => []
        },
      },
      "id" => "#{resource.id}",
      "type" => "resources",
      "links" => %{"self" => "/api/resources/#{resource.id}"},
      "attributes" => @valid_attrs
                    |> string_keys
                    |> dasherize_keys
    }
  end

  test "throws error for invalid resource id", %{conn: conn} do
    conn = get conn, resource_path(conn, :show, -1)

    assert conn.status == 404
    assert json_api_response(conn)["errors"] == not_found("resource")
  end

  test "unauthenticated user can't update resource", %{conn: conn} do
    resource = insert(:resource)
    data = %{data: %{attributes: %{title: "Not secure"}}}

    conn = put conn, resource_path(conn, :update, resource), data

    assert conn.status == 401
    assert json_api_response(conn)["errors"] == unauthorized("resource", "update")
    resource = Repo.get!(Resource, resource.id)
    assert resource.title == @valid_attrs[:title]
  end

  test "unauthenticated user can't delete resource", %{conn: conn} do
    resource = insert(:resource)

    conn = delete conn, resource_path(conn, :update, resource)

    assert conn.status == 401
    assert json_api_response(conn)["errors"] == unauthorized("resource", "delete")
    resource = Repo.get!(Resource, resource.id)
    assert resource
  end

  test "non-admin user can't update resource", %{conn: conn} do
    conn = authenticated(conn)
    resource = insert(:resource)
    data = %{data: %{attributes: %{title: "Not secure"}}}

    conn = put conn, resource_path(conn, :update, resource), data

    assert conn.status == 401
    assert json_api_response(conn)["errors"] == unauthorized("resource", "update")
    resource = Repo.get!(Resource, resource.id)
    assert resource.title == @valid_attrs[:title]
  end

  test "non-admin user can't delete resource", %{conn: conn} do
    conn = authenticated(conn)
    resource = insert(:resource)

    conn = delete conn, resource_path(conn, :update, resource)

    assert conn.status == 401
    assert json_api_response(conn)["errors"] == unauthorized("resource", "delete")
    resource = Repo.get!(Resource, resource.id)
    assert resource
  end

  test "admin user can create resource", %{conn: conn} do
    conn = admin(conn)
    person = insert(:person)
    attributes = @valid_attrs
      |> dasherize_keys
    data = %{
      data: %{
        type: "resources",
        attributes: attributes,
        relationships: %{
          authors: %{ data: [%{ type: "people", id: "#{person.id}" }] }
        }
      }
    }

    conn = post conn, resource_path(conn, :create), data

    assert conn.status == 201
    resource_id = String.to_integer json_api_response(conn)["data"]["id"]
    assert json_api_response(conn)["data"] == %{
      "relationships" => %{
        "authors" => %{
          "data" => [%{ "type" => "people", "id" => "#{person.id}" }]
        },
        "show-notes" => %{},
      },
      "id" => "#{resource_id}",
      "type" => "resources",
      "links" => %{"self" => "/api/resources/#{resource_id}"},
      "attributes" => string_keys(attributes)
    }
    assert Resource.count == 1
    assert Repo.get!(Resource, resource_id)
  end

  test "admin user can update resource", %{conn: conn} do
    conn = admin(conn)
    resource = insert(:resource)
    attributes = %{title: "Better Title"}
    data = %{data: %{id: "#{resource.id}", type: "resources", attributes: attributes}}

    conn = put conn, resource_path(conn, :update, resource), data

    assert conn.status == 200
    assert json_api_response(conn)["data"]["attributes"]["title"] == "Better Title"
    assert Resource.count == 1
    resource = Repo.get!(Resource, resource.id)
    assert resource.title == "Better Title"
  end

  test "admin user sees validation messages when creating resource", %{conn: conn} do
    conn = admin(conn)
    data = %{data: %{type: "resources", attributes: @invalid_attrs}}

    conn = post conn, resource_path(conn, :create), data

    assert conn.status == 422
    assert (json_api_response(conn)["errors"] |> sort_by("detail")) == [
      cant_be_blank("title"),
      cant_be_blank("url")
    ] |> sort_by("detail")
  end

  test "admin user sees validation messages when updating resource", %{conn: conn} do
    conn = admin(conn)
    resource = insert(:resource)
    data = %{data: %{id: "#{resource.id}", type: "resources", attributes: %{"title" => nil}}}

    conn = put conn, resource_path(conn, :update, resource), data

    assert conn.status == 422
    assert json_api_response(conn)["errors"] == [
      cant_be_blank("title")
    ]
  end

  test "admin user can delete resource", %{conn: conn} do
    conn = admin(conn)
    resource = insert(:resource)

    conn = delete conn, resource_path(conn, :update, resource)

    assert conn.status == 204
    assert Resource.count() == 0
  end

end
