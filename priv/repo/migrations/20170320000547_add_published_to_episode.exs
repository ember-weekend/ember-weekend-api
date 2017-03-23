defmodule EmberWeekendApi.Repo.Migrations.AddPublishedToEpisode do
  use Ecto.Migration

  def up do
    alter table(:episodes) do
      add :published, :boolean, default: false, null: false
    end
    execute("UPDATE episodes SET published = true")
  end

  def down do
    alter table(:episodes) do
      remove(:published)
    end
  end
end
