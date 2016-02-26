defmodule EmberWeekendApi.URLFormatTest do
  use EmberWeekendApi.ConnCase

  test "adds json-api headers to *.json-api GET requests", %{conn: conn} do
    conn = get conn, "#{episode_path(conn, :index)}.json-api"
    assert conn.status == 200
    assert json_api_response(conn)["data"] == []
  end

end
