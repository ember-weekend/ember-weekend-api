defmodule EmberWeekendApi.Repo.Migrations.AddNoteToShowNote do
  use Ecto.Migration

  def change do
    alter table(:show_notes) do
      add :note, :string
    end
  end

  def down do
    alter table(:show_notes) do
      remove(:note)
    end
  end
end
