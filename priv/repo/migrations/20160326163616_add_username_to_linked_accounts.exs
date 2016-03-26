defmodule EmberWeekendApi.Repo.Migrations.AddUsernameToLinkedAccounts do
  use Ecto.Migration

  def change do
    alter table(:linked_accounts) do
      add :username, :string
    end
    create index(:linked_accounts, [:username,:provider], unique: true)
  end
end
