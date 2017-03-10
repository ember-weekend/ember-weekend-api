defmodule EmberWeekendApi.Github.HTTPClient do

  def get_access_token(code, state) do
    body = {:form, [
        client_id: client_id(), redirect_uri: redirect_uri(),
        code: code, client_secret: client_secret(), state: state]}
    headers = %{
      "Content-type" => "application/x-www-form-urlencoded",
      "Accept" => "application/json"
    }
    case HTTPoison.post(access_token_url(), body, headers) do
      {:ok, %HTTPoison.Response{body: body}} ->
        case JSON.decode(body) do
          {:ok, %{"access_token" => access_token}} ->
            {:ok, %{access_token: access_token}}
          {:ok, %{"error_description" => message}} ->
            {:error, %{message: message}}
          {:error, message } -> {:error, %{message: message}}
        end
      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, %{message: reason}}
    end
  end

  def get_user_data(access_token) do
    headers = %{
      "Authorization" => "token #{access_token}"
    }
    case HTTPoison.get("https://api.github.com/user", headers) do
      {:ok, %HTTPoison.Response{body: body, status_code: 200}} ->
        case JSON.decode(body) do
          {:ok, %{"id" => id, "name" => name, "login" => login }} ->
            {:ok, %{
                provider_id: "#{id}",
                name: name,
                username: login
              }}
        end
      {:ok, %HTTPoison.Response{body: body, status_code: 401}} ->
        case JSON.decode(body) do
          {:ok, %{"message" => message}} ->
            {:error, %{message: message}}
        end
      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, %{message: reason}}
    end
  end

  defp access_token_url do
    "https://github.com/login/oauth/access_token"
  end

  defp client_id do
    if Mix.env == :prod do
      System.get_env("GITHUB_CLIENT_ID")
    else
      Application.get_env(:ember_weekend_api, EmberWeekendApi.Github)[:client_id]
    end
  end

  defp client_secret do
    if Mix.env == :prod do
      System.get_env("GITHUB_CLIENT_SECRET")
    else
      Application.get_env(:ember_weekend_api, EmberWeekendApi.Github)[:client_secret]
    end
  end

  defp redirect_uri do
    if Mix.env == :prod do
      System.get_env("GITHUB_REDIRECT_URI")
    else
      Application.get_env(:ember_weekend_api, EmberWeekendApi.Github)[:redirect_uri]
    end
  end

end
