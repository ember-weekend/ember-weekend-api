defmodule EmberWeekendApi.SessionControllerTest do
  use EmberWeekendApi.ConnCase
  alias EmberWeekendApi.User
  alias EmberWeekendApi.Session
  alias EmberWeekendApi.LinkedAccount

  @valid_params   %{
    data: %{
      attributes: %{
        provider: "github", code: "valid_code", state: "123456"
      }
  }}
  @invalid_params %{
    data: %{
      attributes: %{
        provider: "github", code: "invalid_code", state: "123456"
      }
  }}
  @valid_linked   %{
    username: "tinyrick",
    provider: "github",
    access_token: "valid_token",
    provider_id: "1"
  }
  @github_user    %{"name" => "Rick Sanchez", "username" => "tinyrick"}

  defp setup_conn(conn) do
    conn = conn
      |> put_req_header("accept", "application/vnd.api+json")
      |> put_req_header("content-type", "application/vnd.api+json")
    {:ok, conn: conn}
  end

  setup %{conn: conn} do
    setup_conn conn
  end

  test "if not present, creates a user for the github account", %{conn: conn} do

    conn = post conn, session_path(conn, :create), @valid_params

    assert conn.status == 201
    assert json_api_response(conn)["data"]["attributes"]["token"]

    included = json_api_response(conn)["included"] |> List.first

    assert included["type"] == "users"
    assert included["attributes"] == @github_user

    assert LinkedAccount.count == 1
    assert Session.count == 1
    assert User.count == 1

    user = User.first
    assert user.name == "Rick Sanchez"
    assert user.username == "tinyrick"

    linked = LinkedAccount.first
    assert linked.user_id == user.id
    assert linked.provider == "github"
    assert linked.provider_id == "1"
    assert linked.username == "tinyrick"

    session = Session.first
    assert session.user_id == user.id

  end

  test "signs in existing user with linked github account", %{conn: conn} do
    user = Repo.insert! User.changeset %User{}, @github_user
    Repo.insert! LinkedAccount.changeset %LinkedAccount{
      user_id: user.id,
      provider: "github",
      provider_id: "1"
    }, @valid_linked

    conn = post conn, session_path(conn, :create), @valid_params

    assert conn.status == 201
    assert json_api_response(conn)["data"]["attributes"]["token"]

    included = json_api_response(conn)["included"] |> List.first

    assert included["type"] == "users"
    assert included["attributes"] == @github_user

    assert LinkedAccount.count == 1
    assert Session.count == 1
    assert User.count == 1

    linked = LinkedAccount.first
    assert linked.user_id == user.id
    assert linked.provider == "github"
    assert linked.provider_id == "1"

    session = Session.first
    assert session.user_id == user.id

    conn = build_conn()
    {:ok, conn: conn} = setup_conn conn
    conn = post conn, session_path(conn, :create), @valid_params
    assert conn.status == 201
  end

  test "signs in existing user and links github account", %{conn: conn} do
    user = Repo.insert! User.changeset %User{}, @github_user

    conn = post conn, session_path(conn, :create), @valid_params

    assert conn.status == 201
    assert json_api_response(conn)["data"]["attributes"]["token"]

    included = json_api_response(conn)["included"] |> List.first

    assert included["type"] == "users"
    assert included["attributes"] == @github_user

    assert LinkedAccount.count == 1
    assert Session.count == 1
    assert User.count == 1

    linked = LinkedAccount.first
    assert linked.user_id == user.id
    assert linked.provider == "github"
    assert linked.provider_id == "1"

    session = Session.first
    assert session.user_id == user.id
  end

  test "returns an error if the code is invalid", %{conn: conn} do
    conn = post conn, session_path(conn, :create), @invalid_params

    assert conn.status == 422
    json = json_api_response(conn)
    error = json["errors"] |> List.first

    assert json["errors"] |> Enum.count == 1
    assert error["status"] == 422
    assert error["title"]  == "Failed to create session"
    assert error["detail"] == "Invalid code"

    assert LinkedAccount.count == 0
    assert Session.count == 0
    assert User.count == 0
  end

  test "signs out", %{conn: conn} do
    token = "VALID"
    session = Repo.insert! %Session{ token: token}

    conn = delete conn, "/api/sessions/#{token}"

    assert conn.status == 204
    refute Repo.get(Session, session.id)
  end

  test "signs out unknown token", %{conn: conn} do
    token = "INVALID"

    conn = delete conn, "/api/sessions/#{token}"

    assert conn.status == 404
    json = json_api_response(conn)
    error = json["errors"] |> List.first

    assert json["errors"] |> Enum.count == 1

    assert error["status"] == 404
    assert error["title"]  == "Failed to delete session"
    assert error["detail"] == "Invalid token"
  end
end
