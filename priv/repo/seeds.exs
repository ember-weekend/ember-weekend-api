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
alias EmberWeekendApi.Person
alias EmberWeekendApi.Resource
alias EmberWeekendApi.ResourceAuthor
alias EmberWeekendApi.ShowNote

Repo.delete_all(ShowNote)
Repo.delete_all(Episode)
Repo.delete_all(ResourceAuthor)
Repo.delete_all(Person)
Repo.delete_all(Resource)

[
  %Episode{
    title: "Pilot",
    description: "Rick moves in with his daughter's family and becomes a bad influence on his grandson, Morty.",
    slug: "pilot",
    release_date: Timex.Date.from({2013, 12, 2}),
    filename: "s01e01",
    duration: "1:00:00"
  },
  %Episode{
    title: "Lawnmower Dog",
    description: "Rick helps Jerry with the dog and incept Goldenfold.",
    slug: "lawnmower-dog",
    release_date: Timex.Date.from({2013, 12, 9}),
    filename: "s01e02",
    duration: "1:00:00"
  },
  %Episode{
    title: "Anatomy Park",
    description: "Rick and Morty try to save the life of a homeless man; Jerry's parents visit.",
    slug: "anatomy-park",
    release_date: Timex.Date.from({2013, 12, 15}),
    filename: "s01e03",
    duration: "1:00:00"
  }
] |> Enum.each(&Repo.insert!(&1))

[%Person{
    name: "Jerry Smith",
    handle: "dr_pluto",
    url: "http://rickandmorty.wikia.com/wiki/Jerry_Smith",
    avatar_url: "http://vignette3.wikia.nocookie.net/rickandmorty/images/5/5d/Jerry_S01E11_Sad.JPG/revision/latest?cb=20140501090439"
  }
] |> Enum.each(&Repo.insert!(&1))

[%Resource{
    title: "Plumbuses",
    url: "http://rickandmorty.wikia.com/wiki/Plumbus"
  }
] |> Enum.each(&Repo.insert!(&1))

[%ResourceAuthor{
    resource_id: (Repo.all(Resource) |> List.first).id,
    author_id: (Repo.all(Person) |> List.first).id
  }
] |> Enum.each(&Repo.insert!(&1))

[%ShowNote{
    resource_id: (Repo.all(Resource) |> List.first).id,
    episode_id: (Repo.all(Episode) |> List.first).id,
    time_stamp: "01:12"
  }
] |> Enum.each(&Repo.insert!(&1))
