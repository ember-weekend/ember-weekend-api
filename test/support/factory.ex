defmodule EmberWeekendApi.Factory do
  use ExMachina.Ecto, repo: EmberWeekendApi.Repo
  alias EmberWeekendApi.Web.{Episode, Person, Resource, ShowNote, ResourceAuthor}

  def episode_factory do
    title = Faker.Lorem.words(%Range{first: 1, last: 8})
    today = Timex.now
    unix = Timex.to_unix(today)
    release_date = Timex.from_unix(:rand.uniform(unix))

    %Episode{
      number: sequence("number", &(&1)),
      length: :rand.uniform(10000),
      title: Enum.join(title, " "),
      description: Faker.Lorem.sentence(20),
      slug: Enum.join(title, "-"),
      release_date: release_date,
      filename: Enum.join(Enum.concat(title, [".mp3"]), "-"),
      duration: sequence("duration", &"00:#{&1}")
    }
  end

  def person_factory() do
    %Person{
      name: "Jerry Smith",
      handle: "dr_pluto",
      tagline: "Well look where being smart got you.",
      bio: "Jerry can sometimes become misguided by his insecurities.",
      url: "http://rickandmorty.wikia.com/wiki/Jerry_Smith",
      avatar_url: "http://vignette3.wikia.nocookie.net/rickandmorty/images/5/5d/Jerry_S01E11_Sad.JPG/revision/latest?cb=20140501090439"
    }
  end

  def resource_author_factory() do
    %ResourceAuthor{
      author: build(:person),
      resource: build(:resource)
    }
  end

  def resource_factory() do
    %Resource{
      title: "Plumbuses",
      url: "http://rickandmorty.wikia.com/wiki/Plumbus",
      resource_authors: [],
    }
  end

  def show_note_factory() do
    %ShowNote{
      episode: build(:episode),
      resource: build(:resource),
      time_stamp: "01:14",
    }
  end

end
