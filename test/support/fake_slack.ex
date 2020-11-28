defmodule Xlack.FakeSlack do
  def start_link do
    Application.put_env(:xlack, :url, "http://localhost:51345")

    Plug.Adapters.Cowboy.http(
      Xlack.FakeSlack.Router,
      [],
      port: 51345,
      dispatch: dispatch()
    )
  end

  def stop do
    Plug.Adapters.Cowboy.shutdown(Xlack.FakeSlack.Router)
  end

  defp dispatch do
    [
      {
        :_,
        [
          {"/ws", Xlack.FakeSlack.Websocket, []},
          {:_, Plug.Adapters.Cowboy.Handler, {Xlack.FakeSlack.Router, []}}
        ]
      }
    ]
  end
end
