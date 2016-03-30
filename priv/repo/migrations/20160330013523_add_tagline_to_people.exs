defmodule EmberWeekendApi.Repo.Migrations.AddTaglineToPeople do
  use Ecto.Migration

  def change do
    alter table(:people) do
      add :tagline, :text
    end
  end
end
