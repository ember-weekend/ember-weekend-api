defmodule EmberWeekendApi.ErrorHandler do
  import Plug.Conn, only: [halt: 1]
  import Phoenix.Controller, only: [json: 2]

  def render_errors(conn, [errors: [%{}] = errors]) do
    conn
    |> Phoenix.Controller.json(%{errors: errors})
    |> Plug.Conn.halt
  end

  def render_errors(conn, [errors: errors]) do
    conn
    |> Phoenix.Controller.json(%{errors: encode_errors(errors)})
    |> Plug.Conn.halt

  end

  defp encode_errors(errors) do
    Enum.reduce errors, [],fn {k, v}, acc ->
      error = Map.put(%{}, "status", "422")
      |> Map.put("source", %{pointer: "/data/attributes/#{k}"})
      |> Map.put("title", v)
      |> Map.put("detail", "#{k} #{v}")
      List.insert_at acc, -1, error
    end
  end
end
