defmodule EmberWeekendApi.Web.ErrorView do

  def render("404.json-api", _assigns) do
    %{errors: [%{detail: "Route not found"}]}
  end

  def render("500.json-api", _assigns) do
    %{errors: [%{detail: "Internal server error"}]}
  end

  def render("errors.json-api", %{errors: errors}) do
    %{errors: errors}
  end

  def render("500.html", _assigns) do
    "Internal server error"
  end

  def template_not_found(_template, assigns) do
    render "500.json-api", assigns
  end

end
