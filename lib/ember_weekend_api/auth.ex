defmodule EmberWeekendApi.Auth do
  alias EmberWeekendApi.ControllerErrors

  def admin?(conn) do
    case conn.assigns[:current_user] do
      nil -> false
      user -> user
        |> linked_accounts
        |> Enum.map(fn(account) -> account.username end)
        |> Enum.map_reduce(false, fn(username, admin) ->
          is_admin = Enum.member?(admin_usernames(), username)
          { is_admin, admin || is_admin }
        end)
        |> elem(1)
    end
  end

  def admin_usernames do
    Application.get_env(:ember_weekend_api, :admins)
  end

  def linked_accounts(user) do
    case user.linked_accounts do
      %Ecto.Association.NotLoaded{} ->
        user
        |> Ecto.assoc(:linked_accounts)
        |> EmberWeekendApi.Repo.all
      other -> other
    end
  end

  def authenticate(conn, :admin) do
    if admin?(conn) do
      conn
    else
      ControllerErrors.unauthorized(conn)
    end
  end

end
