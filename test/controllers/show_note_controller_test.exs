defmodule EmberWeekendApi.ShowNoteControllerTest do
  use EmberWeekendApi.Web.ConnCase

  setup %{conn: conn} do
    conn = conn
    |> put_req_header("accept", "application/vnd.api+json")
    |> put_req_header("content-type", "application/vnd.api+json")
    {:ok, conn: conn}
  end

  test "lists all entries on index", %{conn: conn} do
    ra = insert(:resource_author)
    resource = ra.resource
    author = ra.author
    show_note = insert(:show_note, resource: resource)

    conn = get conn, show_note_path(conn, :index)
    resp = json_api_response(conn)

    assert conn.status == 200
    assert [author_incl, resource_incl] = Enum.sort_by(resp["included"], & Map.get(&1, "type"))

    assert resource_incl == %{
      "id" => "#{resource.id}",
      "type" => "resources",
      "links" => %{"self" => "/api/resources/#{resource.id}"},
      "relationships" => %{
        "authors" => %{
          "data" => [%{ "type" => "people", "id" => "#{author.id}" }]
        },
        "show-notes" => %{},
      },
      "attributes" => %{
        "title" =>  resource.title,
        "url" => resource.url,
    }}

    assert author_incl == %{
      "id" => "#{author.id}",
      "type" => "people",
      "relationships" => %{
        "episodes" => %{},
        "resources" => %{},
      },
      "links" => %{"self" => "/api/people/#{author.id}"},
      "attributes" => %{
        "name" => author.name,
        "avatar-url" => author.avatar_url,
        "handle" => author.handle,
        "tagline" => author.tagline,
        "bio" => author.bio,
        "url" => author.url,
    }}

    assert json_api_response(conn)["data"] == [%{
      "relationships" => %{
        "resource" => %{
          "data" => %{ "type" => "resources", "id" => "#{resource.id}" }
        },
        "episode" => %{
          "data" => %{ "type" => "episodes", "id" => "#{show_note.episode.id}" }
        }
      },
      "links" => %{"self" => "/api/show-notes/#{show_note.id}"},
      "id" => "#{show_note.id}",
      "type" => "show-notes",
      "attributes" => %{"time-stamp" => "01:14", "note" => "Wubalubadub"}
    }]
  end

  test "admin user can create show note", %{conn: conn} do
    conn = admin(conn)
    ra = insert(:resource_author)
    resource = ra.resource
    episode = insert(:episode)

    data = %{
      data: %{
        type: "show-notes",
        attributes: %{"time-stamp" => "01:14", "note" => "My Note"},
        relationships: %{
          "resource" => %{ "data" => %{ "type" => "resources", "id" => "#{resource.id}" } },
          "episode"  => %{ "data" => %{ "type" => "episodes",  "id" => "#{episode.id}"  } }
        }
      }
    }

    conn = post conn, show_note_path(conn, :create), data

    assert conn.status == 201
    show_note_id = String.to_integer json_api_response(conn)["data"]["id"]
    assert json_api_response(conn)["data"] == %{
      "id" => "#{show_note_id}",
      "type" => "show-notes",
      "links" => %{"self" => "/api/show-notes/#{show_note_id}"},
      "attributes" => %{"time-stamp" => "01:14", "note" => "My Note"},
      "relationships" => %{
        "resource" => %{ "data" => %{ "type" => "resources", "id" => "#{resource.id}" } },
        "episode"  => %{ "data" => %{ "type" => "episodes",  "id" => "#{episode.id}"  } }
      }
    }
    assert ShowNote.count == 1
    assert Repo.get!(ShowNote, show_note_id)
  end

  test "admin user can create show note without resource", %{conn: conn} do
    conn = admin(conn)
    episode = insert(:episode)

    data = %{
      data: %{
        type: "show-notes",
        attributes: %{"time-stamp" => "01:14", "note" => "My Note"},
        relationships: %{
          "episode"  => %{ "data" => %{ "type" => "episodes",  "id" => "#{episode.id}"  } }
        }
      }
    }

    conn = post conn, show_note_path(conn, :create), data

    assert conn.status == 201
    show_note_id = String.to_integer json_api_response(conn)["data"]["id"]
    assert json_api_response(conn)["data"] == %{
      "id" => "#{show_note_id}",
      "type" => "show-notes",
      "links" => %{"self" => "/api/show-notes/#{show_note_id}"},
      "attributes" => %{"time-stamp" => "01:14", "note" => "My Note"},
      "relationships" => %{
        "resource" => %{ "data" => nil },
        "episode"  => %{ "data" => %{ "type" => "episodes",  "id" => "#{episode.id}"  } }
      }
    }
    assert ShowNote.count == 1
    assert Repo.get!(ShowNote, show_note_id)
  end


  test "admin user can update show note attributes", %{conn: conn} do
    conn = admin(conn)
    ra = insert(:resource_author)
    resource = ra.resource
    show_note = insert(:show_note, resource: resource)
    episode = show_note.episode

    updated_attrs = %{time_stamp: "10:00", note: "A Note"}
    data = %{
      data: %{
        type: "show-notes",
        attributes: updated_attrs,
        relationships: %{
          "resource" => %{ "data" => %{ "type" => "resources", "id" => "#{resource.id}" } },
          "episode"  => %{ "data" => %{ "type" => "episodes",  "id" => "#{episode.id}"  } }
        }
      }
    }

    conn = put conn, show_note_path(conn, :update, show_note), data

    assert conn.status == 200
    show_note_id = String.to_integer json_api_response(conn)["data"]["id"]
    assert json_api_response(conn)["data"] == %{
      "id" => "#{show_note_id}",
      "type" => "show-notes",
      "links" => %{"self" => "/api/show-notes/#{show_note_id}"},
      "attributes" => updated_attrs
                    |> string_keys
                    |> dasherize_keys,
      "relationships" => %{
        "resource" => %{ "data" => %{ "type" => "resources", "id" => "#{resource.id}" } },
        "episode"  => %{ "data" => %{ "type" => "episodes",  "id" => "#{episode.id}"  } }
      }
    }
    assert ShowNote.count == 1
    assert Repo.get!(ShowNote, show_note_id)
  end

  test "admin user can update show note relationships", %{conn: conn} do
    conn = admin(conn)
    ra1 = insert(:resource_author)
    show_note1 = insert(:show_note, resource: ra1.resource)

    ra2 = insert(:resource_author)
    episode2 = insert(:episode)

    updated_attrs = %{time_stamp: "10:00", note: "A Note"}
    data = %{
      data: %{
        type: "show-notes",
        attributes: updated_attrs,
        relationships: %{
          "resource" => %{ "data" => %{ "type" => "resources", "id" => "#{ra2.resource.id}" } },
          "episode"  => %{ "data" => %{ "type" => "episodes",  "id" => "#{episode2.id}"  } }
        }
      }
    }

    conn = put conn, show_note_path(conn, :update, show_note1), data

    assert conn.status == 200
    show_note_id = String.to_integer json_api_response(conn)["data"]["id"]
    assert json_api_response(conn)["data"] == %{
      "id" => "#{show_note_id}",
      "type" => "show-notes",
      "links" => %{"self" => "/api/show-notes/#{show_note_id}"},
      "attributes" => updated_attrs
                    |> string_keys
                    |> dasherize_keys,
      "relationships" => %{
        "resource" => %{ "data" => %{ "type" => "resources", "id" => "#{ra2.resource.id}" } },
        "episode"  => %{ "data" => %{ "type" => "episodes",  "id" => "#{episode2.id}"  } }
      }
    }
    assert ShowNote.count == 1
    assert Repo.get!(ShowNote, show_note_id)
  end

  test "admin user can delete show note", %{conn: conn} do
    conn = admin(conn)
    show_note = insert(:show_note)

    conn = delete conn, show_note_path(conn, :update, show_note)

    assert conn.status == 204
    assert ShowNote.count() == 0
  end
end
