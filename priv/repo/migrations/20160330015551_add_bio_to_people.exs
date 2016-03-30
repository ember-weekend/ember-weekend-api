defmodule EmberWeekendApi.Repo.Migrations.AddBioToPeople do
  use Ecto.Migration

  def change do
    alter table(:people) do
      add :bio, :text
    end
  end
end
