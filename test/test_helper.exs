ExUnit.start

Mix.Task.run "ecto.create", ~w(-r EmberWeekendApi.Repo --quiet)
Mix.Task.run "ecto.migrate", ~w(-r EmberWeekendApi.Repo --quiet)
Ecto.Adapters.SQL.begin_test_transaction(EmberWeekendApi.Repo)

