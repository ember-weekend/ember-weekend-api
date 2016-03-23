defmodule EmberWeekendApi.ShowNoteControllerTest do
  use EmberWeekendApi.ConnCase
  alias EmberWeekendApi.ShowNote
  alias EmberWeekendApi.Resource
  alias EmberWeekendApi.Person
  alias EmberWeekendApi.ResourceAuthor
  alias EmberWeekendApi.Episode

  @valid_attrs %{time_stamp: "01:14"}

  @invalid_attrs %{}

  @valid_resource_attrs %{
    title: "Plumbuses",
    url: "http://rickandmorty.wikia.com/wiki/Plumbus"
  }

  @valid_person_attrs %{
    name: "Jerry Smith",
    handle: "dr_pluto",
    url: "http://rickandmorty.wikia.com/wiki/Jerry_Smith",
    avatar_url: "http://vignette3.wikia.nocookie.net/rickandmorty/images/5/5d/Jerry_S01E11_Sad.JPG/revision/latest?cb=20140501090439"
  }

  @valid_episode_attrs %{
    title: "Anatomy Park",
    description: "Rick and Morty try to save the life of a homeless man; Jerry's parents visit.",
    slug: "anatomy-park",
    release_date: Timex.Date.from({2013, 12, 15}),
    filename: "s01e03",
    duration: "1:00:00"
  }

  setup %{conn: conn} do
    conn = conn
    |> put_req_header("accept", "application/vnd.api+json")
    |> put_req_header("content-type", "application/vnd.api+json")
    {:ok, conn: conn}
  end

  test "lists all entries on index", %{conn: conn} do
    person = Repo.insert! Map.merge(%Person{}, @valid_person_attrs)
    resource = Repo.insert! Map.merge(%Resource{}, @valid_resource_attrs)
    Repo.insert! %ResourceAuthor{resource_id: resource.id, author_id: person.id}
    episode = Repo.insert! Map.merge(%Episode{}, @valid_episode_attrs)
    show_note = Repo.insert! Map.merge(%ShowNote{episode_id: episode.id, resource_id: resource.id}, @valid_attrs)

    conn = get conn, show_note_path(conn, :index)

    assert conn.status == 200
    assert json_api_response(conn)["included"] == [%{
          "id" => "#{person.id}",
          "type" => "people",
          "links" => %{"self" => "/api/people/#{person.id}"},
          "attributes" => @valid_person_attrs
                        |> string_keys
                        |> dasherize_keys
        },%{
          "id" => "#{resource.id}",
          "type" => "resources",
          "links" => %{"self" => "/api/resources/#{resource.id}"},
          "relationships" => %{
            "authors" => %{
              "data" => [%{ "type" => "people", "id" => "#{person.id}" }]
            }
          },
          "attributes" => @valid_resource_attrs
                        |> string_keys
                        |> dasherize_keys
    }]
    assert json_api_response(conn)["data"] == [%{
      "relationships" => %{
        "resource" => %{
          "data" => %{ "type" => "resources", "id" => "#{resource.id}" }
        },
        "episode" => %{
          "data" => %{ "type" => "episodes", "id" => "#{episode.id}" }
        }
      },
      "links" => %{"self" => "/api/show-notes/#{show_note.id}"},
      "id" => "#{show_note.id}",
      "type" => "show-notes",
      "attributes" => @valid_attrs
                    |> string_keys
                    |> dasherize_keys
    }]
  end

  test "authenticated user can create show note", %{conn: conn} do
    person = Repo.insert! Map.merge(%Person{}, @valid_person_attrs)
    resource = Repo.insert! Map.merge(%Resource{}, @valid_resource_attrs)
    Repo.insert! %ResourceAuthor{resource_id: resource.id, author_id: person.id}
    episode = Repo.insert! Map.merge(%Episode{}, @valid_episode_attrs)

    data = %{
      data: %{
        type: "show-notes",
        attributes: @valid_attrs,
        relationships: %{
          "resource" => %{ "data" => %{ "type" => "resources", "id" => "#{resource.id}" } },
          "episode"  => %{ "data" => %{ "type" => "episodes",  "id" => "#{episode.id}"  } }
        }
      }
    }

    conn = authenticated(conn)
    conn = post conn, show_note_path(conn, :create, data)

    assert conn.status == 201
    show_note_id = String.to_integer json_api_response(conn)["data"]["id"]
    assert json_api_response(conn)["data"] == %{
      "id" => "#{show_note_id}",
      "type" => "show-notes",
      "links" => %{"self" => "/api/show-notes/#{show_note_id}"},
      "attributes" => @valid_attrs
                    |> string_keys
                    |> dasherize_keys,
      "relationships" => %{
        "resource" => %{ "data" => %{ "type" => "resources", "id" => "#{resource.id}" } },
        "episode"  => %{ "data" => %{ "type" => "episodes",  "id" => "#{episode.id}"  } }
      }
    }
    assert Repo.all(ShowNote) |> Enum.count == 1
    assert Repo.get!(ShowNote, show_note_id)
  end

end
