defmodule EmberWeekendApi.Person do
  use EmberWeekendApi.Web, :model

  schema "people" do
    field :name, :string
    field :handle, :string
    field :url, :string
    field :avatar_url, :string
    field :tagline, :string
    field :bio, :string

    timestamps
  end

  @required_fields ~w(name handle url avatar_url)
  @optional_fields ~w(tagline bio)

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
