defmodule EmberWeekendApi.Github.Stub do

  def get_access_token(code, _) do
    case code do
      "valid_code" ->
        {:ok, %{ access_token: "valid_token" }}
      _ ->
        {:error, %{ message: "Invalid code" }}
    end
  end

  def get_user_data(access_token) do
    case access_token do
      "valid_token" ->
        {:ok, %{name: "Rick Sanchez", username: "tinyrick", provider_id: "1"}}
      _ ->
        {:error, %{message: "Invalid token"}}
    end
  end

end
