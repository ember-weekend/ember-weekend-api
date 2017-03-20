defmodule EmberWeekendApi.FeedControllerTest do
  use EmberWeekendApi.ConnCase
  alias EmberWeekendApi.ShowNote
  alias EmberWeekendApi.Resource
  alias EmberWeekendApi.Person
  alias EmberWeekendApi.ResourceAuthor
  alias EmberWeekendApi.Episode
  alias EmberWeekendApi.EpisodeGuest

  import EmberWeekendApi.Factory

  setup %{conn: conn} do
    {:ok, conn: conn}
  end

  test "renders an XML RSS feed", %{conn: conn} do
    conn = get conn, feed_path(conn, :index)
    {:ok, feed, _} = FeederEx.parse(conn.resp_body)
    assert feed.title == "Ember Weekend"
    assert Enum.count(feed.entries) == 0
  end

  test "feed contains episodes", %{conn: conn} do
    insert_list(3, :episode)
    conn = get conn, feed_path(conn, :index)
    {:ok, feed, _} = FeederEx.parse(conn.resp_body)
    assert Enum.count(feed.entries) == 3
  end

  test "feed items have episode attributes", %{conn: conn} do
    insert(:episode, %{
             number: 1,
             title: "first episode",
             description: "description",
             slug: "first-episode"
           })
    conn = get conn, feed_path(conn, :index)
    {:ok, feed, _} = FeederEx.parse(conn.resp_body)
    item = List.first(feed.entries)
    assert item.title == "Episode 1: first episode"
    assert item.subtitle == "description"
    assert item.link == "https://emberweekend.com/first-episode"
  end

end
