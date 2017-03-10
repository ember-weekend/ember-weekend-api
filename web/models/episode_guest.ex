defmodule EmberWeekendApi.EpisodeGuest do
  use EmberWeekendApi.Web, :model

  schema "episode_guest" do
    belongs_to :episode, EmberWeekendApi.Episode
    belongs_to :guest, EmberWeekendApi.Person

    timestamps()
  end

  @required_fields ~w(episode_id guest_id)a
  @optional_fields ~w()a

  @doc """
  Creates a changeset based on the `struct` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @optional_fields ++ @required_fields)
    |> validate_required(@required_fields)
  end
end
