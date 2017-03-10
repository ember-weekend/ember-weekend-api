defmodule EmberWeekendApi.Person do
  use EmberWeekendApi.Web, :model

  schema "people" do
    field :name, :string
    field :handle, :string
    field :url, :string
    field :avatar_url, :string
    field :tagline, :string
    field :bio, :string

    timestamps()
  end

  @required_fields ~w(name handle url avatar_url)a
  @optional_fields ~w(tagline bio)a

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
