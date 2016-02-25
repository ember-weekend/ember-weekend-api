defmodule EmberWeekendApi.SessionTest do
  use EmberWeekendApi.ModelCase

  alias EmberWeekendApi.Session

  @valid_attrs %{token: "some content", user_id: 1}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Session.changeset(%Session{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Session.changeset(%Session{}, @invalid_attrs)
    refute changeset.valid?
  end
end
