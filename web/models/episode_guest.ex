defmodule EmberWeekendApi.EpisodeGuest do
  use EmberWeekendApi.Web, :model

  schema "episode_guest" do
    belongs_to :episode, EmberWeekendApi.Episode
    belongs_to :guest, EmberWeekendApi.Person

    timestamps
  end

  @required_fields ~w(episode_id guest_id)
  @optional_fields ~w()

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end
end
