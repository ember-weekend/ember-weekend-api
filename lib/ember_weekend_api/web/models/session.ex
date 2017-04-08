defmodule EmberWeekendApi.Web.Session do
  use EmberWeekendApi.Web, :model

  schema "sessions" do
    field :token, :string
    belongs_to :user, EmberWeekendApi.Web.User

    timestamps()
  end

  @required_fields ~w(token user_id)a
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
