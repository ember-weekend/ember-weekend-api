defmodule EmberWeekendApi.Web.FeedController do
  use EmberWeekendApi.Web, :controller
  alias EmberWeekendApi.Web.Episode

  def index(conn, _params) do
    episodes = from(e in Episode.published(Episode),
                    order_by: [desc: e.number],
                    left_join: show_notes in assoc(e, :show_notes),
                    left_join: resource in assoc(show_notes, :resource),
                    preload: [show_notes: {show_notes, resource: resource }]
                  )
    |> Repo.all
    render(conn, "index.xml", episodes: episodes)
  end

end
