defmodule EmberWeekendApi.Seeder do
  alias EmberWeekendApi.Repo
  alias EmberWeekendApi.Web.{Episode, Person, Resource, ResourceAuthor, ShowNote, EpisodeGuest}

  @seed_data %{
    Episode => [%{
      number: 1,
      title: "Pilot",
      description: "Rick moves in with his daughter's family and becomes a bad influence on his grandson, Morty.",
      slug: "pilot",
      release_date: ~D[2013-12-02],
      filename: "s01e01",
      duration: "1:00:00",
      published: true
    },
    %{
      number: 2,
      title: "Lawnmower Dog",
      description: "Rick helps Jerry with the dog and incept Goldenfold.",
      slug: "lawnmower-dog",
      release_date: ~D[2013-12-09],
      filename: "s01e02",
      duration: "1:00:00",
      published: true
    },
    %{
      number: 3,
      title: "Anatomy Park",
      description: "Rick and Morty try to save the life of a homeless man; Jerry's parents visit.",
      slug: "anatomy-park",
      release_date: ~D[2013-12-15],
      filename: "s01e03",
      duration: "1:00:00"
    }],

    Person => [%{
      name: "Jerry Smith",
      handle: "dr_pluto",
      tagline: "Well look where being smart got you.",
      bio: "Jerry can sometimes become misguided by his insecurities.",
      url: "http://rickandmorty.wikia.com/wiki/Jerry_Smith",
      avatar_url: "http://vignette3.wikia.nocookie.net/rickandmorty/images/5/5d/Jerry_S01E11_Sad.JPG/revision/latest?cb=20140501090439"
    },
    %{
      name: "Rick Sanchez",
      handle: "tinyrick",
      tagline: "wubbalubbadubdub",
      bio: "Rick's most prominent personality trait barring his drug and alcohol dependency is his sociopathy.",
      url: "http://rickandmorty.wikia.com/wiki/Rick_Sanchez",
      avatar_url: "http://vignette4.wikia.nocookie.net/rickandmorty/images/d/dd/Rick.png/revision/latest?cb=20131230003659"
    }],

    Resource => [%{
      title: "Plumbuses",
      url: "http://rickandmorty.wikia.com/wiki/Plumbus"
    }],

    ResourceAuthor => [],
    ShowNote => [],
    EpisodeGuest => [],
  }

  def reset do
    @seed_data
    |> Map.keys
    |> Enum.each(&reset_module/1)
  end


  def seed do
    Enum.each(@seed_data, &seed_module/1)

    %ResourceAuthor{
      resource: Resource.first,
      author: Person.first
    } |> Repo.insert!

    %ShowNote{
      resource: Resource.first,
      episode: Episode.first,
      time_stamp: "01:12"
    } |> Repo.insert!

    %EpisodeGuest{
      episode: Episode.first,
      guest: Person.first
    } |> Repo.insert!
  end

  defp reset_module(module) do
    Repo.delete_all(module)

    new_row = struct(module)
    {_, table} = new_row.__meta__.source
    Ecto.Adapters.SQL.query(EmberWeekendApi.Repo, "ALTER SEQUENCE #{table}_id_seq RESTART WITH 1;", [])
  end

  defp seed_module({module, rows}) do
    ts = %{
      inserted_at: DateTime.utc_now,
      updated_at: DateTime.utc_now
    }
    Repo.insert_all(module, Enum.map(rows, &Map.merge(&1, ts)))
  end
end
