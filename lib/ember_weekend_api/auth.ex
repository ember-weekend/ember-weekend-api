defmodule EmberWeekendApi.Auth do
  alias EmberWeekendApi.ControllerErrors

  def admin?(conn) do
    conn.assigns[:current_user] != nil
  end

  def authenticate(conn, :admin) do
    if admin?(conn) do
      conn
    else
      ControllerErrors.unauthorized(conn)
    end
  end

end
