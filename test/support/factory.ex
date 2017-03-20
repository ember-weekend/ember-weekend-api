defmodule EmberWeekendApi.Factory do
  use ExMachina.Ecto, repo: EmberWeekendApi.Repo

  def episode_factory do
    title = Faker.Lorem.words(%Range{first: 1, last: 8})
    today = Timex.now
    unix = Timex.to_unix(today)
    release_date = Timex.from_unix(:rand.uniform(unix))

    %EmberWeekendApi.Episode{
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

end
