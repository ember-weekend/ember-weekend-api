defmodule EmberWeekendApi.FeedController do
  use EmberWeekendApi.Web, :controller
  alias EmberWeekendApi.Episode

  def index(conn, _params) do
    episodes = Repo.all(Episode)
    render(conn, "index.xml", episodes: episodes)
  end

end
