defmodule EmberWeekendApi.Resource do
  use EmberWeekendApi.Web, :model
  alias EmberWeekendApi.ResourceAuthor
  alias EmberWeekendApi.ShowNote

  schema "resources" do
    field :title, :string
    field :url, :string
    has_many :resource_authors, ResourceAuthor
    has_many :authors, through: [:resource_authors, :author]
    has_many :show_notes, ShowNote

    timestamps()
  end

  @required_fields ~w(title url)a
  @optional_fields ~w()a

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @optional_fields ++ @required_fields)
    |> validate_required(@required_fields)
  end
end
