defmodule EmberWeekendApi.UserTest do
  use EmberWeekendApi.ModelCase

  alias EmberWeekendApi.User

  @valid_attrs %{name: "some content", username: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = User.changeset(%User{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = User.changeset(%User{}, @invalid_attrs)
    refute changeset.valid?
  end
end
