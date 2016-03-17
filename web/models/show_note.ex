defmodule EmberWeekendApi.ShowNote do
  use EmberWeekendApi.Web, :model

  schema "show_notes" do
    field :time_stamp, :string
    belongs_to :resource, EmberWeekendApi.Resource
    belongs_to :episode, EmberWeekendApi.Episode

    timestamps
  end

  @required_fields ~w(time_stamp)
  @optional_fields ~w()

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end
end
