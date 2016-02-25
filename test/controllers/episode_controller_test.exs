defmodule EmberWeekendApi.EpisodeControllerTest do
  use EmberWeekendApi.ConnCase

  alias EmberWeekendApi.Episode

  @valid_attrs %{
    title: "Anatomy Park",
    description: "Rick and Morty try to save the life of a homeless man; Jerry's parents visit.",
    slug: "anatomy-park",
    release_date: %Ecto.Date{year: 2013, month: 12, day: 15},
    filename: "s01e03",
    duration: "1:00:00"
  }

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  test "lists all episodes on index", %{conn: conn} do
    conn = get conn, episode_path(conn, :index)
    assert json_response(conn, 200)["data"] == []
  end

  test "shows episode", %{conn: conn} do
    episode = Repo.insert! Map.merge(%Episode{}, @valid_attrs)
    conn = get conn, episode_path(conn, :show, episode)
    assert json_response(conn, 200)["data"] == %{
      "id" => Integer.to_string(episode.id),
      "type" => "episode",
      "attributes" => %{
        "title" => episode.title,
        "description" => episode.description,
        "slug" => episode.slug,
        "release-date" => "2013-12-15",
        "filename" => episode.filename,
        "duration" => episode.duration
      }
    }
  end

  test "throws error for invalid episode id", %{conn: conn} do
    conn = get conn, episode_path(conn, :show, -1)
    assert json_response(conn, 404)["errors"] == [%{
      "title" => "Not found",
      "status" => 404,
      "source" => %{
        "pointer" => "/id"
      },
      "detail" => "No episode found for the given id"
    }]
  end
end
