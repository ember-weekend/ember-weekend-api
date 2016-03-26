defmodule EmberWeekendApi.LinkedAccountTest do
  use EmberWeekendApi.ModelCase

  alias EmberWeekendApi.LinkedAccount

  @valid_attrs %{
    username: "some_username",
    access_token: "some content",
    provider: "some content",
    provider_id: "some content",
    user_id: 1
  }
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = LinkedAccount.changeset(%LinkedAccount{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = LinkedAccount.changeset(%LinkedAccount{}, @invalid_attrs)
    refute changeset.valid?
  end
end
