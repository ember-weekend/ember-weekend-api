defmodule EmberWeekendApi.EpisodeTest do
  use EmberWeekendApi.Web.ModelCase

  alias EmberWeekendApi.Web.Episode

  @valid_attrs %{number: 1, description: "some content",
    duration: "some content", filename: "some content",
    release_date: "2010-04-17", slug: "some content",
    title: "some content", published: true, length: 1}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Episode.changeset(%Episode{}, @valid_attrs)
    assert changeset.errors == []
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Episode.changeset(%Episode{}, @invalid_attrs)
    refute changeset.valid?
  end
end
