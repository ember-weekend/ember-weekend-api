defmodule EmberWeekendApi.ShowNoteController do
  use EmberWeekendApi.Web, :controller

  alias EmberWeekendApi.ShowNote

  def index(conn, _params) do
    show_notes = Repo.all(ShowNote)
    render(conn, data: show_notes, opts: [include: "resource,resource.authors"])
  end
end
