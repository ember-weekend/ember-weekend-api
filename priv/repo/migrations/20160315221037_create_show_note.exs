defmodule EmberWeekendApi.Repo.Migrations.CreateShowNote do
  use Ecto.Migration

  def change do
    create table(:show_notes) do
      add :time_stamp, :string
      add :resource_id, references(:resources, on_delete: :nothing)
      add :episode_id, references(:episodes, on_delete: :nothing)

      timestamps()
    end
    create index(:show_notes, [:resource_id])
    create index(:show_notes, [:episode_id])

  end
end
