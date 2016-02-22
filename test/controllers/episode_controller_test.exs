defmodule EmberWeekendApi.EpisodeControllerTest do
  use EmberWeekendApi.ConnCase

  alias EmberWeekendApi.Episode
  @valid_attrs %{description: "some content", duration: "some content", filename: "some content", release_date: "2010-04-17", slug: "some content", title: "some content"}
  @invalid_attrs %{}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  test "lists all episodes on index", %{conn: conn} do
    conn = get conn, episode_path(conn, :index)
    assert json_response(conn, 200)["data"] == []
  end

  test "shows episode", %{conn: conn} do
    episode = Repo.insert! %Episode{}
    conn = get conn, episode_path(conn, :show, episode)
    assert json_response(conn, 200)["data"] == %{"id" => Integer.to_string(episode.id),
      "type" => "episode",
      "attributes" => %{
        "title" => episode.title,
        "description" => episode.description,
        "slug" => episode.slug,
        "release-date" => episode.release_date,
        "filename" => episode.filename,
        "duration" => episode.duration
      }
    }
  end

  test "does not show episode and instead throw error when id is nonexistent", %{conn: conn} do
    conn = get conn, episode_path(conn, :show, -1)
    assert json_response(conn, 404)["errors"] == [%{"title" => "Not Found",
      "status" => "404",
      "source" => %{
        "pointer" => "/data/attributes/id"
      },
      "detail" => "No episode found for the given id"
    }]
  end
end
