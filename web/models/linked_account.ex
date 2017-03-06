defmodule EmberWeekendApi.LinkedAccount do
  use EmberWeekendApi.Web, :model

  schema "linked_accounts" do
    field :username, :string
    field :provider, :string
    field :access_token, :string
    field :provider_id, :string
    belongs_to :user, EmberWeekendApi.User

    timestamps
  end

  @required_fields ~w(provider access_token provider_id user_id username)
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
