defmodule EmberWeekendApi.Repo.Migrations.AddNumberToEpisodes do
  use Ecto.Migration

  def change do
    alter table(:episodes) do
      add :number, :integer
    end
    create index(:episodes, [:number], unique: true)
  end
end
