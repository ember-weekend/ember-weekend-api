defmodule EmberWeekendApi.Auth do
  def admin?(conn) do
    conn.assigns[:current_user] != nil
  end
end
