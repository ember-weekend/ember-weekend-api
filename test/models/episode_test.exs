defmodule EmberWeekendApi.EpisodeTest do
  use EmberWeekendApi.ModelCase

  alias EmberWeekendApi.Episode

  @valid_attrs %{description: "some content", duration: "some content", filename: "some content", release_date: "2010-04-17", slug: "some content", title: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Episode.changeset(%Episode{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Episode.changeset(%Episode{}, @invalid_attrs)
    refute changeset.valid?
  end
end
