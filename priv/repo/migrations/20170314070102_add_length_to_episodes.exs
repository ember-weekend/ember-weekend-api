defmodule EmberWeekendApi.Repo.Migrations.AddLengthToEpisodes do
  use Ecto.Migration

  def change do
    alter table(:episodes) do
      add :length, :integer
    end
  end
end
