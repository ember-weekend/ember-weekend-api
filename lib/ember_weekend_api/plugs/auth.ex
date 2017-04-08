defmodule EmberWeekendApi.Plugs.Auth do
  import Plug.Conn
  import Phoenix.Controller
  alias EmberWeekendApi.Repo
  alias EmberWeekendApi.Web.User
  alias EmberWeekendApi.Web.Session

  def init(default), do: default

  def call(conn, _) do
    header = get_req_header(conn, "authorization")
    |> List.first || ""
    case Regex.named_captures(~r/token\W+(?<token>.*)/i, header) do
      %{"token" => token} ->
        case Repo.get_by(Session, token: token) do
          nil ->
            conn
            |> put_view(EmberWeekendApi.Web.ErrorView)
            |> put_status(:unauthorized)
            |> render(:errors, errors: [%{
              status: "401",
              source: %{pointer: "/token"},
              title: "Unauthorized",
              detail: "The authentication token is invalid"}])
            |> halt()
          session ->
            user = Repo.get(User, session.user_id)
            assign(conn, :current_user, user)
        end
      _ -> conn
    end
  end

end
