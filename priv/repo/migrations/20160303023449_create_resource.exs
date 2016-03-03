defmodule EmberWeekendApi.Repo.Migrations.CreateResource do
  use Ecto.Migration

  def change do
    create table(:resources) do
      add :title, :string
      add :url, :string

      timestamps
    end

  end
end
