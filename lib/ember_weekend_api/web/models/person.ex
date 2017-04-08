defmodule EmberWeekendApi.Web.Person do
  use EmberWeekendApi.Web, :model
  alias EmberWeekendApi.Web.EpisodeGuest
  alias EmberWeekendApi.Web.ResourceAuthor

  schema "people" do
    field :name, :string
    field :handle, :string
    field :url, :string
    field :avatar_url, :string
    field :tagline, :string
    field :bio, :string
    has_many :episode_guests, EpisodeGuest, foreign_key: :guest_id
    has_many :episodes, through: [:episode_guests, :episode]
    has_many :resource_authors, ResourceAuthor, foreign_key: :author_id
    has_many :resources, through: [:resource_authors, :resource]

    timestamps()
  end

  @required_fields ~w(name url)a
  @optional_fields ~w(tagline bio handle avatar_url)a

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
