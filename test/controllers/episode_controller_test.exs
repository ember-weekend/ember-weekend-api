defmodule EmberWeekendApi.EpisodeControllerTest do
  use EmberWeekendApi.ConnCase
  alias EmberWeekendApi.Episode

  @valid_attrs %{
    title: "Anatomy Park",
    description: "Rick and Morty try to save the life of a homeless man; Jerry's parents visit.",
    slug: "anatomy-park",
    release_date: Timex.Date.from({2013, 12, 15}),
    filename: "s01e03",
    duration: "1:00:00"
  }

  @invalid_attrs %{}

  setup %{conn: conn} do
    conn = conn
    |> put_req_header("accept", "application/vnd.api+json")
    |> put_req_header("content-type", "application/vnd.api+json")
    {:ok, conn: conn}
  end

  test "lists all episodes on index", %{conn: conn} do
    conn = get conn, episode_path(conn, :index)

    assert conn.status == 200
    assert json_api_response(conn)["data"] == []
  end

  test "shows episode", %{conn: conn} do
    episode = Repo.insert! Map.merge(%Episode{}, @valid_attrs)

    conn = get conn, episode_path(conn, :show, episode)

    attributes = @valid_attrs
      |> string_keys
      |> dasherize_keys
      |> convert_dates
    assert conn.status == 200
    assert json_api_response(conn)["data"] == %{
      "id" => "#{episode.id}",
      "type" => "episode",
      "attributes" => string_keys(attributes)
    }
  end

  test "throws error for invalid episode id", %{conn: conn} do
    conn = get conn, episode_path(conn, :show, -1)

    assert conn.status == 404
    assert json_api_response(conn)["errors"] == not_found("episode")
  end

  test "unauthenticated user can't update episode", %{conn: conn} do
    episode = Repo.insert! Map.merge(%Episode{}, @valid_attrs)
    data = %{data: %{attributes: %{title: "Not secure"}}}

    conn = put conn, episode_path(conn, :update, episode, data)

    assert conn.status == 401
    assert json_api_response(conn)["errors"] == unauthorized("episode", "update")
    episode = Repo.get!(Episode, episode.id)
    assert episode.title == @valid_attrs[:title]
  end

  test "unauthenticated user can't delete episode", %{conn: conn} do
    episode = Repo.insert! Map.merge(%Episode{}, @valid_attrs)

    conn = delete conn, episode_path(conn, :update, episode)

    assert conn.status == 401
    assert json_api_response(conn)["errors"] == unauthorized("episode", "delete")
    episode = Repo.get!(Episode, episode.id)
    assert episode
  end

  test "unauthenticated user can't create episode", %{conn: conn} do
    params = Map.merge(@valid_attrs, %{release_date: "2013-12-15"})

    conn = post conn, episode_path(conn, :create, params)

    assert conn.status == 401
    assert json_api_response(conn)["errors"] == unauthorized("episode", "create")
    assert Repo.all(Episode) |> Enum.count() == 0
  end

  test "authenticated user can delete episode", %{conn: conn} do
    conn = authenticated(conn)
    episode = Repo.insert! Map.merge(%Episode{}, @valid_attrs)

    conn = delete conn, episode_path(conn, :update, episode)

    assert conn.status == 204
    assert Repo.all(Episode) |> Enum.count() == 0
  end

  test "authenticated user can create episode", %{conn: conn} do
    conn = authenticated(conn)
    attributes = @valid_attrs
      |> Map.delete(:release_date)
      |> Map.merge(%{"release-date": "2013-12-15"})
    data = %{data: %{type: "episode", attributes: attributes}}

    conn = post conn, episode_path(conn, :create, data)

    assert conn.status == 201
    episode_id = String.to_integer json_api_response(conn)["data"]["id"]
    assert json_api_response(conn)["data"] == %{
      "id" => "#{episode_id}",
      "type" => "episode",
      "attributes" => string_keys(attributes)
    }
    assert Repo.all(Episode) |> Enum.count == 1
    assert Repo.get!(Episode, episode_id)
  end

  test "authenticated user can update episode", %{conn: conn} do
    conn = authenticated(conn)
    episode = Repo.insert! Map.merge(%Episode{}, @valid_attrs)
    attributes = %{title: "Better title"}
    data = %{data: %{id: "#{episode.id}", type: "episode", attributes: attributes}}

    conn = put conn, episode_path(conn, :update, episode, data)

    assert conn.status == 200
    assert json_api_response(conn)["data"]["attributes"]["title"] == "Better title"
    assert Repo.all(Episode) |> Enum.count == 1
    episode = Repo.get!(Episode, episode.id)
    assert episode.title == "Better title"
  end

  test "authenticated user sees validation messages when creating episode", %{conn: conn} do
    conn = authenticated(conn)
    data = %{data: %{type: "episode", attributes: @invalid_attrs}}

    conn = post conn, episode_path(conn, :create), data

    assert conn.status == 422
    assert (json_api_response(conn)["errors"] |> sort_by("detail")) == [
      cant_be_blank("title"),
      cant_be_blank("description"),
      cant_be_blank("release_date"),
      cant_be_blank("slug"),
      cant_be_blank("duration"),
      cant_be_blank("filename")
    ] |> sort_by("detail")
  end

  test "authenticated user sees validation messages when updating episode", %{conn: conn} do
    conn = authenticated(conn)
    episode = Repo.insert! Map.merge(%Episode{}, @valid_attrs)
    data = %{data: %{id: "#{episode.id}", type: "episode", attributes: %{ title: nil }}}
      |> string_keys
      |> dasherize_keys
      |> convert_dates

    conn = put conn, episode_path(conn, :update, episode), data

    assert conn.status == 422
    assert json_api_response(conn)["errors"] == [cant_be_blank("title")]
  end

end
