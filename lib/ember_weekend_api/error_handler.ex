defmodule EmberWeekendApi.ErrorHandler do
  import Plug.Conn, only: [halt: 1]
  import Phoenix.Controller, only: [json: 2]

  def render_errors(conn, [errors: [%{}] = errors]) do
    conn
    |> Phoenix.Controller.json(%{errors: errors})
    |> Plug.Conn.halt
  end

  def render_errors(conn, [errors: errors, title: title]) do
    conn
    |> Phoenix.Controller.json(%{errors: encode_errors(errors, title)})
    |> Plug.Conn.halt
  end

  def render_errors(conn, [errors: errors]) do
    conn
    |> Phoenix.Controller.json(%{errors: encode_errors(errors, "Invalid attribute")})
    |> Plug.Conn.halt
  end

  defp encode_errors(errors, title) do
    Enum.reduce errors, [],fn {k, v}, acc ->
      error = Map.put(%{}, "status", 422)
      |> Map.put("source", %{pointer: "/data/attributes/#{k}"})
      |> Map.put("title", title)
      |> Map.put("detail", v)
      List.insert_at acc, -1, error
    end
  end
end
