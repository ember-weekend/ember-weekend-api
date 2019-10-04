defmodule EmberWeekendApi.Web.User do
  use EmberWeekendApi.Web, :model
  alias EmberWeekendApi.Web.LinkedAccount
  alias EmberWeekendApi.Web.Session

  schema "users" do
    field :name, :string
    field :username, :string
    has_many :linked_accounts, LinkedAccount
    has_many :sessions, Session

    timestamps([type: :utc_datetime_usec])
  end

  @required_fields ~w(name username)a
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
