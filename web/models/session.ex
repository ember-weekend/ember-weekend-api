defmodule EmberWeekendApi.Session do
  use EmberWeekendApi.Web, :model

  schema "sessions" do
    field :token, :string
    belongs_to :user, EmberWeekendApi.User

    timestamps
  end

  @required_fields ~w(token user_id)
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
