defmodule EmberWeekendApi.PersonTest do
  use EmberWeekendApi.ModelCase

  alias EmberWeekendApi.Person

  @valid_attrs %{avatar_url: "some content", handle: "some content", name: "some content", url: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Person.changeset(%Person{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Person.changeset(%Person{}, @invalid_attrs)
    refute changeset.valid?
  end
end
