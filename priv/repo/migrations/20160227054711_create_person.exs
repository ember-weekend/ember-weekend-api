defmodule EmberWeekendApi.Repo.Migrations.CreatePerson do
  use Ecto.Migration

  def change do
    create table(:people) do
      add :name, :string
      add :handle, :string
      add :url, :string
      add :avatar_url, :string

      timestamps()
    end

  end
end
