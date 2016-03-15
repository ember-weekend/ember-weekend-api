defmodule EmberWeekendApi.Repo.Migrations.CreateResourceAuthor do
  use Ecto.Migration

  def change do
    create table(:resource_authors) do
      add :author_id, references(:people, on_delete: :nothing)
      add :resource_id, references(:resources, on_delete: :nothing)

      timestamps
    end
    create index(:resource_authors, [:author_id])
    create index(:resource_authors, [:resource_id])

  end
end
