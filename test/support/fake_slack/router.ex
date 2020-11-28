defmodule Xlack.FakeSlack.Router do
  use Plug.Router
  import Plug.Conn
  import Xlack.Factory

  plug(:match)
  plug(:dispatch)

  get "/api/rtm.start" do
    conn = fetch_query_params(conn)

    pid = Application.get_env(:xlack, :test_pid)
    send(pid, {:token, conn.query_params["token"]})

    response = ~S(
      {
        "ok": true,
        "url": "ws://localhost:51345/ws",
        "self": { "id": "U0123abcd", "name": "bot" },
        "team": { "id": "T4567abcd", "name": "Example Team" },
        "bots": [{ "id": "U0123abcd", "name": "bot" }],
        "channels": [],
        "groups": [],
        "users": [],
        "ims": []
      }
    )

    send_resp(conn, 200, response)
  end

  post "/api/:endpoint" do
    conn = fetch_query_params(conn)
    {:ok, body, conn} = read_body(conn)
    params = URI.decode_query(body)
    limit = Map.get(params, :limit, 5)

    entities =
      build_list(limit, String.to_atom(String.replace(conn.params["endpoint"], ".", "_")))

    entity_type =
      conn.params["endpoint"]
      |> String.split(".")
      |> List.first()
      |> case do
        "conversations" -> "channels"
        type -> type
      end

    resp = %{
      entity_type => entities,
      "ok" => true,
      "response_metadata" => %{
        "next_cursor" => "dGVhbTpDMDJHQ0ZUSDA=",
        "warnings" => ["superfluous_charset"]
      },
      "warning" => "superfluous_charset"
    }

    send_resp(conn, 200, Jason.encode!(resp))
  end
end
