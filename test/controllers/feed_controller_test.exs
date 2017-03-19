defmodule EmberWeekendApi.FeedControllerTest do
  use EmberWeekendApi.ConnCase
  alias EmberWeekendApi.ShowNote
  alias EmberWeekendApi.Resource
  alias EmberWeekendApi.Person
  alias EmberWeekendApi.ResourceAuthor
  alias EmberWeekendApi.Episode
  alias EmberWeekendApi.EpisodeGuest

  setup %{conn: conn} do
    {:ok, conn: conn}
  end

  test "renders an XML RSS feed", %{conn: conn} do
    conn = get conn, feed_path(conn, :index)
    {:ok, feed, _} = FeederEx.parse(conn.resp_body)
    assert feed.title == "Ember Weekend"
    assert Enum.count(feed.entries) == 0
  end

end
