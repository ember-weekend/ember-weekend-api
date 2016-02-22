defmodule EmberWeekendApi.PageController do
  use EmberWeekendApi.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
