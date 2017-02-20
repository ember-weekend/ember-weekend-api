defmodule EmberWeekendApi.Plugs.URLFormat do

  def init(default), do: default

  def call(conn, _default) do
    conn.path_info |> List.last |> String.split(".") |> Enum.reverse |> case do
      [ _ ] -> conn
      [ format | fragments ] ->
        new_path       = fragments |> Enum.reverse |> Enum.join(".")
        path_fragments = List.replace_at conn.path_info, -1, new_path
        new_headers = conn.req_headers
        |> List.keydelete("accept", 0)
        |> List.keydelete("content-type", 0)
        case format_to_mime(format) do
          nil -> conn
          mime ->
            new_headers = new_headers ++ [
              {"accept", mime},
              {"content-type", mime}]
            %{conn | path_info: path_fragments, req_headers: new_headers}
        end
    end
  end

  defp format_to_mime(format) do
    mimes = Application.get_env(:plug, :mimes)
    Map.values(mimes) |> Enum.find_index(fn(m) -> m == [format] end) |> case do
      nil -> nil
      index ->
        {:ok, mime} = Enum.fetch(Map.keys(mimes), index)
        mime
    end
  end
end
