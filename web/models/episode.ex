defmodule EmberWeekendApi.Episode do
  use EmberWeekendApi.Web, :model
  alias EmberWeekendApi.ShowNote
  alias EmberWeekendApi.Person
  alias EmberWeekendApi.EpisodeGuest

  schema "episodes" do
    field :number, :integer
    field :title, :string
    field :description, :string
    field :slug, :string
    field :release_date, Timex.Ecto.Date
    field :filename, :string
    field :duration, :string
    has_many :show_notes, ShowNote
    has_many :episode_guests, EpisodeGuest
    has_many :guests, through: [:episode_guests, :guest]

    timestamps
  end

  @required_fields ~w(number title description slug release_date filename duration)
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
