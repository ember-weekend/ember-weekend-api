defmodule EmberWeekendApi.EpisodeControllerTest do
  use EmberWeekendApi.ConnCase
  alias EmberWeekendApi.ShowNote
  alias EmberWeekendApi.Resource
  alias EmberWeekendApi.Person
  alias EmberWeekendApi.ResourceAuthor
  alias EmberWeekendApi.Episode
  alias EmberWeekendApi.EpisodeGuest

  @valid_attrs %{
    number: 1,
    title: "Anatomy Park",
    description: "Rick and Morty try to save the life of a homeless man; Jerry's parents visit.",
    slug: "anatomy-park",
    release_date: Timex.Date.from({2013, 12, 15}),
    filename: "s01e03",
    duration: "1:00:00"
  }

  @invalid_attrs %{}

  @valid_show_note_attrs %{time_stamp: "01:14"}

  @valid_resource_attrs %{
    title: "Plumbuses",
    url: "http://rickandmorty.wikia.com/wiki/Plumbus"
  }

  @valid_person_attrs %{
    name: "Jerry Smith",
    handle: "dr_pluto",
    bio: "Jerry can sometimes become misguided by his insecurities.",
    tagline: "Well look where being smart got you.",
    url: "http://rickandmorty.wikia.com/wiki/Jerry_Smith",
    avatar_url: "http://vignette3.wikia.nocookie.net/rickandmorty/images/5/5d/Jerry_S01E11_Sad.JPG/revision/latest?cb=20140501090439"
  }

  setup %{conn: conn} do
    conn = conn
    |> put_req_header("accept", "application/vnd.api+json")
    |> put_req_header("content-type", "application/vnd.api+json")
    {:ok, conn: conn}
  end

  test "lists all episodes on index", %{conn: conn} do
    episode = Repo.insert! Map.merge(%Episode{}, @valid_attrs)
    conn = get conn, episode_path(conn, :index)

    assert conn.status == 200

    assert json_api_response(conn)["data"] == [%{
      "id" => "#{episode.id}",
      "type" => "episodes",
      "attributes" => @valid_attrs
                      |> string_keys
                      |> dasherize_keys
                      |> convert_dates,
      "relationships" => %{
        "guests" => %{
          "data" => []
        },
        "show-notes" => %{
          "data" => []
        }
      }
    }]
  end

  test "shows episode", %{conn: conn} do
    episode = Repo.insert! Map.merge(%Episode{}, @valid_attrs)
    person = Repo.insert! Map.merge(%Person{}, @valid_person_attrs)
    resource = Repo.insert! Map.merge(%Resource{}, @valid_resource_attrs)
    Repo.insert! %ResourceAuthor{resource_id: resource.id, author_id: person.id}
    Repo.insert! %EpisodeGuest{episode_id: episode.id, guest_id: person.id}
    show_note = Repo.insert! Map.merge(%ShowNote{
      episode_id: episode.id, resource_id: resource.id
    }, @valid_show_note_attrs)

    conn = get conn, episode_path(conn, :show, episode)

    assert conn.status == 200
    assert json_api_response(conn)["data"] == %{
      "id" => "#{episode.id}",
      "type" => "episodes",
      "attributes" => @valid_attrs
                      |> string_keys
                      |> dasherize_keys
                      |> convert_dates,
      "relationships" => %{
        "guests" => %{
          "data" => [%{ "type" => "people", "id" => "#{person.id}" }]
        },
        "show-notes" => %{
          "data" => [%{ "type" => "show-notes", "id" => "#{show_note.id}" }]
        }
      }
    }
    assert json_api_response(conn)["included"] == [%{
      "attributes" => @valid_show_note_attrs
                    |> string_keys
                    |> dasherize_keys,
      "id" => "#{show_note.id}",
      "links" => %{"self" => "/api/show-notes/#{show_note.id}"},
      "relationships" => %{
        "resource" => %{ "data" => %{ "type" => "resources", "id" => "#{resource.id}" } },
        "episode"  => %{ "data" => %{ "type" => "episodes",  "id" => "#{episode.id}"  } }
      },
      "type" => "show-notes"
    },%{
      "attributes" => @valid_resource_attrs
                    |> string_keys
                    |> dasherize_keys,
      "id" => "#{resource.id}",
      "links" => %{"self" => "/api/resources/#{resource.id}"},
      "type" => "resources",
      "relationships" => %{
        "authors" => %{ "data" => [%{ "type" => "people", "id" => "#{person.id}" }] },
      }
    },%{
      "attributes" => @valid_person_attrs
                    |> string_keys
                    |> dasherize_keys,
      "id" => "#{person.id}",
      "links" => %{"self" => "/api/people/#{person.id}"},
      "type" => "people"
    }]
  end

  test "shows episode by slug", %{conn: conn} do
    episode = Repo.insert! Map.merge(%Episode{}, @valid_attrs)
    person = Repo.insert! Map.merge(%Person{}, @valid_person_attrs)
    resource = Repo.insert! Map.merge(%Resource{}, @valid_resource_attrs)
    Repo.insert! %ResourceAuthor{resource_id: resource.id, author_id: person.id}
    Repo.insert! %EpisodeGuest{episode_id: episode.id, guest_id: person.id}
    show_note = Repo.insert! Map.merge(%ShowNote{
      episode_id: episode.id, resource_id: resource.id
    }, @valid_show_note_attrs)

    conn = get conn, episode_path(conn, :show, episode.slug)

    assert conn.status == 200
    assert json_api_response(conn)["data"] == %{
      "id" => "#{episode.id}",
      "type" => "episodes",
      "attributes" => @valid_attrs
                      |> string_keys
                      |> dasherize_keys
                      |> convert_dates,
      "relationships" => %{
        "show-notes" => %{
          "data" => [%{ "type" => "show-notes", "id" => "#{show_note.id}" }]
        },
        "guests" => %{
          "data" => [%{ "type" => "people", "id" => "#{person.id}" }]
        }
      }
    }
    assert json_api_response(conn)["included"] == [%{
      "attributes" => @valid_show_note_attrs
                    |> string_keys
                    |> dasherize_keys,
      "id" => "#{show_note.id}",
      "links" => %{"self" => "/api/show-notes/#{show_note.id}"},
      "relationships" => %{
        "resource" => %{ "data" => %{ "type" => "resources", "id" => "#{resource.id}" } },
        "episode"  => %{ "data" => %{ "type" => "episodes",  "id" => "#{episode.id}"  } }
      },
      "type" => "show-notes"
    },%{
      "attributes" => @valid_resource_attrs
                    |> string_keys
                    |> dasherize_keys,
      "id" => "#{resource.id}",
      "links" => %{"self" => "/api/resources/#{resource.id}"},
      "type" => "resources",
      "relationships" => %{
        "authors" => %{ "data" => [%{ "type" => "people", "id" => "#{person.id}" }] },
      }
    },%{
      "attributes" => @valid_person_attrs
                    |> string_keys
                    |> dasherize_keys,
      "id" => "#{person.id}",
      "links" => %{"self" => "/api/people/#{person.id}"},
      "type" => "people"
    }]
  end

  test "throws error for invalid episode id", %{conn: conn} do
    conn = get conn, episode_path(conn, :show, -1)

    assert conn.status == 404
    assert json_api_response(conn)["errors"] == not_found("episode")
  end

  test "unauthenticated user can't update episode", %{conn: conn} do
    episode = Repo.insert! Map.merge(%Episode{}, @valid_attrs)
    data = %{data: %{attributes: %{title: "Not secure"}}}

    conn = put conn, episode_path(conn, :update, episode), data

    assert conn.status == 401
    assert json_api_response(conn)["errors"] == unauthorized("episode", "update")
    episode = Repo.get!(Episode, episode.id)
    assert episode.title == @valid_attrs[:title]
  end

  test "unauthenticated user can't delete episode", %{conn: conn} do
    episode = Repo.insert! Map.merge(%Episode{}, @valid_attrs)

    conn = delete conn, episode_path(conn, :update, episode)

    assert conn.status == 401
    assert json_api_response(conn)["errors"] == unauthorized("episode", "delete")
    episode = Repo.get!(Episode, episode.id)
    assert episode
  end

  test "unauthenticated user can't create episode", %{conn: conn} do
    params = Map.merge(@valid_attrs, %{release_date: "2013-12-15"})

    conn = post conn, episode_path(conn, :create), params

    assert conn.status == 401
    assert json_api_response(conn)["errors"] == unauthorized("episode", "create")
    assert Repo.all(Episode) |> Enum.count() == 0
  end

  test "non-admin user can't update episode", %{conn: conn} do
    conn = authenticated(conn)
    episode = Repo.insert! Map.merge(%Episode{}, @valid_attrs)
    data = %{data: %{attributes: %{title: "Not secure"}}}

    conn = put conn, episode_path(conn, :update, episode), data

    assert conn.status == 401
    assert json_api_response(conn)["errors"] == unauthorized("episode", "update")
    episode = Repo.get!(Episode, episode.id)
    assert episode.title == @valid_attrs[:title]
  end

  test "non-admin user can't delete episode", %{conn: conn} do
    conn = authenticated(conn)
    episode = Repo.insert! Map.merge(%Episode{}, @valid_attrs)

    conn = delete conn, episode_path(conn, :update, episode)

    assert conn.status == 401
    assert json_api_response(conn)["errors"] == unauthorized("episode", "delete")
    episode = Repo.get!(Episode, episode.id)
    assert episode
  end

  test "non-admin user can't create episode", %{conn: conn} do
    conn = authenticated(conn)
    params = Map.merge(@valid_attrs, %{release_date: "2013-12-15"})

    conn = post conn, episode_path(conn, :create), params

    assert conn.status == 401
    assert json_api_response(conn)["errors"] == unauthorized("episode", "create")
    assert Repo.all(Episode) |> Enum.count() == 0
  end

  test "admin user can delete episode", %{conn: conn} do
    conn = admin(conn)
    episode = Repo.insert! Map.merge(%Episode{}, @valid_attrs)

    conn = delete conn, episode_path(conn, :update, episode)

    assert conn.status == 204
    assert Repo.all(Episode) |> Enum.count() == 0
  end

  test "admin user can create episode", %{conn: conn} do
    conn = admin(conn)
    person = Repo.insert! Map.merge(%Person{}, @valid_person_attrs)
    attributes = @valid_attrs
      |> Map.delete(:release_date)
      |> Map.merge(%{"release-date": "2013-12-15"})
    data = %{
      data: %{
        type: "episodes",
        attributes: attributes,
        relationships: %{
          guests: %{ data: [%{ type: "people", id: "#{person.id}" }] }
        }
      }
    }

    conn = post conn, episode_path(conn, :create), data

    assert conn.status == 201
    episode_id = String.to_integer json_api_response(conn)["data"]["id"]
    assert json_api_response(conn)["data"] == %{
      "id" => "#{episode_id}",
      "type" => "episodes",
      "attributes" => attributes
                      |> string_keys
                      |> dasherize_keys
                      |> convert_dates,
      "relationships" => %{
        "show-notes" => %{
          "data" => []
        },
        "guests" => %{
          "data" => [
            %{"type" => "people", "id" => "#{person.id}"}
          ]
        }
      }
    }
    assert Repo.all(Episode) |> Enum.count == 1
    assert Repo.get!(Episode, episode_id)
  end

  test "admin user can update episode", %{conn: conn} do
    conn = admin(conn)
    episode = Repo.insert! Map.merge(%Episode{}, @valid_attrs)
    attributes = %{title: "Better title"}
    data = %{data: %{id: "#{episode.id}", type: "episodes", attributes: attributes}}

    conn = put conn, episode_path(conn, :update, episode), data

    assert conn.status == 200
    assert json_api_response(conn)["data"]["attributes"]["title"] == "Better title"
    assert Repo.all(Episode) |> Enum.count == 1
    episode = Repo.get!(Episode, episode.id)
    assert episode.title == "Better title"
  end

  test "admin user sees validation messages when creating episode", %{conn: conn} do
    conn = admin(conn)
    data = %{data: %{type: "episodes", attributes: @invalid_attrs}}

    conn = post conn, episode_path(conn, :create), data

    assert conn.status == 422
    assert (json_api_response(conn)["errors"] |> sort_by("detail")) == [
      cant_be_blank("number"),
      cant_be_blank("title"),
      cant_be_blank("description"),
      cant_be_blank("release_date"),
      cant_be_blank("slug"),
      cant_be_blank("duration"),
      cant_be_blank("filename")
    ] |> sort_by("detail")
  end

  test "admin user sees validation messages when updating episode", %{conn: conn} do
    conn = admin(conn)
    episode = Repo.insert! Map.merge(%Episode{}, @valid_attrs)
    data = %{data: %{id: "#{episode.id}", type: "episodes", attributes: %{ title: nil }}}
      |> string_keys
      |> dasherize_keys
      |> convert_dates

    conn = put conn, episode_path(conn, :update, episode), data

    assert conn.status == 422
    assert json_api_response(conn)["errors"] == [cant_be_blank("title")]
  end

end
