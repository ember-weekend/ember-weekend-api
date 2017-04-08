defmodule EmberWeekendApi.Web.ResourceAuthor do
  use EmberWeekendApi.Web, :model

  schema "resource_authors" do
    belongs_to :author, EmberWeekendApi.Web.Person
    belongs_to :resource, EmberWeekendApi.Web.Resource

    timestamps()
  end

  @required_fields ~w(author_id resource_id)a
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
