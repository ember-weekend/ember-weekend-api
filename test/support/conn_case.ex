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

    end
  end

  setup tags do
    unless tags[:async] do
      Ecto.Adapters.SQL.restart_test_transaction(EmberWeekendApi.Repo, [])
    end

    {:ok, conn: Phoenix.ConnTest.conn()}
  end
end
