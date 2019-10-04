defmodule EmberWeekendApi.Web.EpisodeGuest do
  use EmberWeekendApi.Web, :model

  schema "episode_guest" do
    belongs_to :episode, EmberWeekendApi.Web.Episode
    belongs_to :guest, EmberWeekendApi.Web.Person

    timestamps([type: :utc_datetime_usec])
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
