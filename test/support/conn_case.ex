defmodule EmberWeekendApi.ConnCase do
  @moduledoc """
  This module defines the test case to be used by
  tests that require setting up a connection.

  Such tests rely on `Phoenix.ConnTest` and also
  imports other functionality to make it easier
  to build and query models.

  Finally, if the test case interacts with the database,
  it cannot be async. For this reason, every test runs
  inside a transaction which is reset at the beginning
  of the test unless the test case is marked as async.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      # Import conveniences for testing with connections
      use Phoenix.ConnTest
      alias Plug.Conn
      require IEx

      alias EmberWeekendApi.Repo
      alias EmberWeekendApi.User
      alias EmberWeekendApi.Session
      import Ecto
      import Ecto.Changeset
      import Ecto.Query, only: [from: 1, from: 2]

      import EmberWeekendApi.Router.Helpers

      # The default endpoint for testing
      @endpoint EmberWeekendApi.Endpoint

      require Logger

      def log(thing) do
        IO.puts "\n"
        Logger.warn "\n\n#{inspect thing}\n"
      end

      def json_api_response(conn) do
        case JSON.decode(conn.resp_body) do
          {:ok, json} ->
            case Conn.get_resp_header(conn, "content-type") do
              [] -> {:error, "Content type was not 'application/vnd.api+json'"}
              ["application/vnd.api+json"] -> json
              ["application/vnd.api+json; charset=utf-8"] -> json
            end
          {:error, error} -> {:error, error}
        end
      end

      def string_keys(map) do
        for {key, val} <- map, into: %{}, do: {"#{key}",val}
      end

      def dasherize_keys(map) do
        for {key, val} <- map, into: %{} do
          {String.replace("#{key}", "_", "-"),val}
        end
      end

      def convert_dates(map) do
        for {key, val} <- map, into: %{} do
          case val do
            %Timex.DateTime{} ->
              {:ok, date} = Timex.DateFormat.format(val, "{YYYY}-{M}-{D}")
              {key, date}
            _ -> {key,val}
          end
        end
      end

      def not_found(model_name) do
        [%{
            "title" => "Not found",
            "status" => 404,
            "source" => %{
              "pointer" => "/id"
            },
          "detail" => "No #{model_name} found for the given id"
        }]
      end

      def unauthorized(model_name, action) do
        [%{
            "source" => %{
              "pointer" => "/token"
            },
          "title" => "Unauthorized",
          "status" => 401,
          "detail" => "Must provide auth token to #{action} #{model_name}"
        }]
      end

      def sort_by(list, attr) do
        list
        |> (Enum.sort &(Enum.sort([&1[attr], &2[attr]])
        |> List.first) == &1[attr])
      end

      def cant_be_blank(attr) do
        humanized = String.replace(attr, "_", " ")
        dasherized = String.replace(attr, "_", "-")
        %{
          "detail" => "#{String.capitalize humanized} can't be blank",
          "source" => %{
            "pointer" => "/data/attributes/#{dasherized}"
          },
          "title" => "can't be blank"
        }
      end

      @valid_user_attrs %{
        name: "Rick Sanchez",
        username: "tinyrick"
      }
      def authenticated(conn) do
        token = "VALID"
        user = Repo.insert! User.changeset %User{}, @valid_user_attrs
        Repo.insert! %Session{token: token, user_id: user.id}
        put_req_header(conn, "authorization", "token #{token}")
      end

    end
  end

  setup tags do
    unless tags[:async] do
      Ecto.Adapters.SQL.restart_test_transaction(EmberWeekendApi.Repo, [])
    end

    {:ok, conn: Phoenix.ConnTest.conn()}
  end
end
