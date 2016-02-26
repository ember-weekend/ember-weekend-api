defmodule EmberWeekendApi.SessionController do
  use EmberWeekendApi.Web, :controller
  alias EmberWeekendApi.User
  alias EmberWeekendApi.Session
  alias EmberWeekendApi.LinkedAccount

  @github_api Application.get_env(:ember_weekend_api, :github_api)

  def create(conn, %{"data" => %{"attributes" => %{"provider" => "github", "code" => code, "state" => state}}}) do
    case @github_api.get_access_token(code, state) do
      {:ok, %{access_token: access_token}} ->
        case create_session(access_token, "github") do
          {:ok, %{user: _, session: session}} ->
            conn
            |> put_status(:created)
            |> render(:show, data: session)
          {:error, errors} ->
            conn
            |> put_status(:unprocessable_entity)
            |> render(:errors, data: errors)
        end
      {:error, %{message: message}} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(:errors, data: %{
          source: %{ pointer: "/code" },
          status: 422,
          title: "Failed to create session",
          detail: message
        })
    end
  end

  def delete(conn, %{"token" => token}) do
    case Repo.get_by(Session, token: token) do
      nil ->
        conn
        |> put_status(:not_found)
        |> render(:errors, data: %{
          source: %{ pointer: "/token" },
          status: 404,
          title: "Failed to delete session",
          detail: "Invalid token"
        })
      session ->
        Repo.delete!(session)
        send_resp(conn, :no_content, "")
    end
  end

  defp create_session(access_token, provider) do
    case @github_api.get_user_data(access_token) do
      {:ok, attrs} ->
        case find_or_create_user(attrs, access_token, provider) do
          {:ok, user} ->
            token = SecureRandom.base64(24)
            changeset = Session.changeset(%Session{}, %{user_id: user.id, token: token})
            case Repo.insert(changeset) do
              {:ok, session} ->
                {:ok, %{session: session, user: user}}
              {:error, changeset} ->
                errors = EmberWeekendApi.ChangesetView.translate_errors(changeset)
                {:error, %{errors: errors}}
            end
          {:error, error} ->
            {:error, error}
        end
      {:error, %{message: message}} ->
        {:error, %{message: message}}
    end
  end

  defp find_or_create_user(attrs, access_token, provider) do
    case Repo.get_by(User, name: attrs[:name]) do
      nil ->
        case create_user(attrs) do
          {:ok, user} ->
            provider_id = attrs[:provider_id]
            case find_or_create_linked_account(user, access_token, provider, provider_id) do
              {:error, error} -> {:error, error}
              _ -> {:ok, user}
            end
          error -> error
        end
      user ->
        provider_id = attrs[:provider_id]
        case find_or_create_linked_account(user, access_token, provider, provider_id) do
          {:error, error} -> {:error, error}
          _ -> {:ok, user}
        end
    end
  end

  defp create_user(attrs) do
    changeset = User.changeset(%User{}, %{name: attrs[:name], username: attrs[:username]})
    case Repo.insert(changeset) do
      {:ok, user} ->
        {:ok, user}
      {:error, changeset} ->
        errors = EmberWeekendApi.ChangesetView.translate_errors(changeset)
        {:error, %{errors: errors}}
    end
  end

  defp find_or_create_linked_account(user, access_token, provider, provider_id) do
    case Repo.get_by(LinkedAccount, access_token: access_token, provider: provider, provider_id: provider_id) do
      nil ->
        changeset = LinkedAccount.changeset(%LinkedAccount{}, %{
          user_id: user.id,
          access_token: access_token,
          provider: provider,
          provider_id: provider_id
        })

        case Repo.insert(changeset) do
          {:error, changeset} ->
            errors = EmberWeekendApi.ChangesetView.translate_errors(changeset)
            {:error, %{errors: errors}}
          linked_account -> linked_account
        end
      linked_account -> linked_account
    end
  end

end
