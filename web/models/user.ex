defmodule EmberWeekendApi.User do
  use EmberWeekendApi.Web, :model
  alias EmberWeekendApi.LinkedAccount
  alias EmberWeekendApi.Session

  schema "users" do
    field :name, :string
    field :username, :string
    has_many :linked_accounts, LinkedAccount
    has_many :sessions, Session

    timestamps
  end

  @required_fields ~w(name username)
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
