defmodule EmberWeekendApi.SessionControllerTest do
  use EmberWeekendApi.Web.ConnCase

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

    assert [included] = json_api_response(conn)["included"]

    assert included["type"] == "users"
    assert included["attributes"] == %{
      "name" => params_for(:user).name,
      "username" => params_for(:user).username
    }

    assert db_user = Repo.get_by(User, username: EmberWeekendApi.Github.Stub.username)
    assert Repo.one(assoc(db_user, :sessions))

    assert linked = Repo.one(assoc(db_user, :linked_accounts))
    assert linked.provider == "github"
    assert linked.provider_id == "1"
  end

  test "signs in existing user with linked github account", %{conn: conn} do
    user = insert(:linked_account).user

    conn = post conn, session_path(conn, :create), @valid_params

    assert conn.status == 201
    assert json_api_response(conn)["data"]["attributes"]["token"]

    [included] = json_api_response(conn)["included"]

    assert included["type"] == "users"
    assert included["attributes"] == %{
      "name" => user.name,
      "username" => user.username
    }

    assert db_user = Repo.get(User, user.id)
    assert Repo.one(assoc(db_user, :sessions))

    assert linked = Repo.one(assoc(db_user, :linked_accounts))
    assert linked.provider == "github"
    assert linked.provider_id == "1"

    conn = build_conn()
    {:ok, conn: conn} = setup_conn conn
    conn = post conn, session_path(conn, :create), @valid_params
    assert conn.status == 201
  end

  test "signs in existing user and links github account", %{conn: conn} do
    user = insert(:user, username: "tinyrick")

    conn = post conn, session_path(conn, :create), @valid_params

    assert conn.status == 201
    assert json_api_response(conn)["data"]["attributes"]["token"]

    assert [included] = json_api_response(conn)["included"]

    assert included["type"] == "users"
    assert included["attributes"] == %{
      "name" => user.name,
      "username" => user.username
    }

    assert db_user = Repo.get(User, user.id)
    assert Repo.one(assoc(db_user, :sessions))

    assert linked = Repo.one(assoc(db_user, :linked_accounts))
    assert linked.provider == "github"
    assert linked.provider_id == "1"
  end

  test "returns an error if the code is invalid", %{conn: conn} do
    conn = post conn, session_path(conn, :create), @invalid_params

    assert conn.status == 422
    json = json_api_response(conn)
    assert [error] = json["errors"]

    assert error["status"] == 422
    assert error["title"]  == "Failed to create session"
    assert error["detail"] == "Invalid code"

    assert LinkedAccount.count == 0
    assert Session.count == 0
    assert User.count == 0
  end

  test "signs out", %{conn: conn} do
    token = "VALID"
    session = Repo.insert! %Session{token: token}

    conn = delete conn, "/api/sessions/#{token}"

    assert conn.status == 204
    refute Repo.get(Session, session.id)
  end

  test "signs out unknown token", %{conn: conn} do
    token = "INVALID"

    conn = delete conn, "/api/sessions/#{token}"

    assert conn.status == 404
    json = json_api_response(conn)
    assert [error] = json["errors"]

    assert error["status"] == 404
    assert error["title"]  == "Failed to delete session"
    assert error["detail"] == "Invalid token"
  end
end
