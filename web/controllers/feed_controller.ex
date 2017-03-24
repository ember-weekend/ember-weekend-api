defmodule EmberWeekendApi.FeedController do
  use EmberWeekendApi.Web, :controller
  alias EmberWeekendApi.Episode

  def index(conn, _params) do
    episodes = Repo.all(from(e in Episode, order_by: [desc: e.number]))
    render(conn, "index.xml", episodes: episodes)
  end

end
