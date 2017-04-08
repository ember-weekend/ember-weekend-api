defmodule EmberWeekendApi.Web.ControllerErrors do
  alias Phoenix.Controller

  def model_name(conn, model_name) do
    Plug.Conn.assign(conn, :model_name, model_name)
  end

  def model_name(conn) do
    to_string conn.assigns[:model_name]
  end

  def unauthorized(conn) do
    action = Atom.to_string Controller.action_name(conn)
    model_name = model_name(conn)
    conn
    |> Plug.Conn.put_status(:unauthorized)
    |> Controller.render(:errors, data: %{
      status: 401,
      source: %{ pointer: "/token" },
      title: "Unauthorized",
      detail: "Must provide auth token to #{action} #{model_name}"
    })
    |> Plug.Conn.halt()
  end

  def not_found(conn) do
    model_name = model_name(conn)
    conn
    |> Plug.Conn.put_status(:not_found)
    |> Controller.render(:errors, data: %{
      source: %{ pointer: "/id" },
      status: 404,
      title: "Not found",
      detail: "No #{model_name} found for the given id"
    })
    |> Plug.Conn.halt()
  end

end
