defmodule EmberWeekendApi.EpisodeGuestTest do
  use EmberWeekendApi.ModelCase

  alias EmberWeekendApi.EpisodeGuest

  @valid_attrs %{episode_id: 1, guest_id: 2}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = EpisodeGuest.changeset(%EpisodeGuest{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = EpisodeGuest.changeset(%EpisodeGuest{}, @invalid_attrs)
    refute changeset.valid?
  end
end
