# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     EmberWeekendApi.Repo.insert!(%EmberWeekendApi.SomeModel{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
alias EmberWeekendApi.Repo
alias EmberWeekendApi.Episode

[
  %Episode{
    title: "Pilot",
    description: "Rick moves in with his daughter's family and becomes a bad influence on his grandson, Morty.",
    slug: "pilot",
    release_date: %Ecto.Date{year: 2013, month: 12, day: 2},
    filename: "s01e01",
    duration: "1:00:00"
  },
  %Episode{
    title: "Lawnmower Dog",
    description: "Rick helps Jerry with the dog and incept Goldenfold.",
    slug: "lawnmower-dog",
    release_date: %Ecto.Date{year: 2013, month: 12, day: 9},
    filename: "s01e02",
    duration: "1:00:00"
  },
  %Episode{
    title: "Anatomy Park",
    description: "Rick and Morty try to save the life of a homeless man; Jerry's parents visit.",
    slug: "anatomy-park",
    release_date: %Ecto.Date{year: 2013, month: 12, day: 15},
    filename: "s01e03",
    duration: "1:00:00"
  }
] |> Enum.each(&Repo.insert!(&1))
