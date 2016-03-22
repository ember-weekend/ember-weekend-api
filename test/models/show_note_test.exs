defmodule EmberWeekendApi.ShowNoteTest do
  use EmberWeekendApi.ModelCase

  alias EmberWeekendApi.ShowNote

  @valid_attrs %{time_stamp: "some content", episode_id: 1, resource_id: 1}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = ShowNote.changeset(%ShowNote{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = ShowNote.changeset(%ShowNote{}, @invalid_attrs)
    refute changeset.valid?
  end
end
