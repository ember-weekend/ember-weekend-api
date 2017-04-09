defmodule EmberWeekendApi.Repo.Migrations.CreateLinkedAccount do
  use Ecto.Migration

  def change do
    create table(:linked_accounts) do
      add :provider, :string
      add :access_token, :string
      add :provider_id, :string
      add :user_id, references(:users, on_delete: :nothing)

      timestamps()
    end
    create index(:linked_accounts, [:user_id])

  end
end
