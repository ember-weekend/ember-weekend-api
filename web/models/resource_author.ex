defmodule EmberWeekendApi.ResourceAuthor do
  use EmberWeekendApi.Web, :model

  schema "resource_authors" do
    belongs_to :author, EmberWeekendApi.Person
    belongs_to :resource, EmberWeekendApi.Resource

    timestamps
  end

  @required_fields ~w(author_id resource_id)
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
