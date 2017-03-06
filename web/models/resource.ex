defmodule EmberWeekendApi.Resource do
  use EmberWeekendApi.Web, :model
  alias EmberWeekendApi.ResourceAuthor

  schema "resources" do
    field :title, :string
    field :url, :string
    has_many :resource_authors, ResourceAuthor
    has_many :authors, through: [:resource_authors, :author]

    timestamps
  end

  @required_fields ~w(title url)
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
