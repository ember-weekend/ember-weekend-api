defmodule EmberWeekendApi.Mixfile do
  use Mix.Project

  def project do
    [app: :ember_weekend_api,
     version: "0.0.1",
     elixir: "~> 1.0",
     elixirc_paths: elixirc_paths(Mix.env),
     compilers: [:phoenix, :gettext] ++ Mix.compilers,
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     aliases: aliases(),
     deps: deps()]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [mod: {EmberWeekendApi, []}]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_),     do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [{:phoenix, "~> 1.3.0-rc.1"},
     {:postgrex, ">= 0.15.0"},
     {:phoenix_ecto, "~> 4.0"},
     {:ecto_sql, "~> 3.0"},
     {:plug_cowboy, "~> 1.0"},
     {:phoenix_html, "~> 2.9"},
     {:phoenix_live_reload, "~> 1.0", only: :dev},
     {:gettext, "~> 0.9"},
     {:cowboy, "~> 1.0"},
     {:httpoison, "~> 0.8.1"},
     {:secure_random, "~>0.2"},
     {:json, "~> 0.3.0"},
     {:timex, "~> 3.1"},
     {:corsica, "~> 0.4"},
     {:feeder_ex, "~> 1.0.1"},
     {:ex_machina, "~> 2.3.0", only: :test},
     {:faker, "~> 0.7", only: :test},
     {:ja_serializer, "~> 0.12.0"}]
  end

  # Aliases are shortcut or tasks specific to the current project.
  # For example, to create, migrate and run the seeds file at once:
  #
  #     $ mix ecto.setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    ["ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
     "ecto.reset": ["ecto.drop", "ecto.setup"],
     "test": ["ecto.create --quiet", "ecto.migrate", "test"]]
  end
end
