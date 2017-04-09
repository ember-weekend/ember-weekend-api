defmodule EmberWeekendApi.Repo.Migrations.CreateEpisodeGuest do
  use Ecto.Migration

  def change do
    create table(:episode_guest) do
      add :episode_id, references(:episodes, on_delete: :nothing)
      add :guest_id, references(:people, on_delete: :nothing)

      timestamps()
    end
    create index(:episode_guest, [:episode_id])
    create index(:episode_guest, [:guest_id])

  end
end
