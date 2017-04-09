defmodule EmberWeekendApi.Repo.Migrations.CreateEpisode do
  use Ecto.Migration

  def change do
    create table(:episodes) do
      add :title, :string
      add :description, :string
      add :slug, :string
      add :release_date, :date
      add :filename, :string
      add :duration, :string

      timestamps()
    end

  end
end
