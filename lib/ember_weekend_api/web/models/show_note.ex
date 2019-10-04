defmodule EmberWeekendApi.Web.ShowNote do
  use EmberWeekendApi.Web, :model

  schema "show_notes" do
    field :time_stamp, :string
    field :note, :string
    belongs_to :resource, EmberWeekendApi.Web.Resource
    belongs_to :episode, EmberWeekendApi.Web.Episode

    timestamps([type: :utc_datetime_usec])
  end

  @required_fields ~w(time_stamp episode_id)a
  @optional_fields ~w(note resource_id)a

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
