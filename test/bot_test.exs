defmodule Xlack.BotTest do
  use ExUnit.Case

  defmodule Bot do
    use Xlack
  end

  @rtm %{
    url: "http://example.com",
    self: %{name: "fake"},
    team: %{name: "Foo"}
  }

  test "init formats rtm results properly" do
    {:reconnect, %{slack: slack, bot_handler: bot_handler}} =
      Xlack.Bot.init(%{
        bot_handler: Bot,
        rtm: @rtm,
        client: FakeWebsocketClient,
        token: "ABC",
        initial_state: nil
      })

    assert bot_handler == Bot
    assert slack.me.name == "fake"
    assert slack.team.name == "Foo"
  end

  defmodule Stubs.Xlack.Rtm do
    def start(_token) do
      {:ok, %{url: "http://www.example.com"}}
    end
  end

  defmodule Stubs.Xlack.WebsocketClient do
    def start_link(_url, _module, _state, _options) do
      {:ok, self()}
    end
  end

  test "can configure the RTM module" do
    original_slack_rtm = Application.get_env(:xlack, :rtm_module, Xlack.Rtm)

    Application.put_env(:xlack, :rtm_module, Stubs.Xlack.Rtm)

    assert {:ok, _pid} =
             Xlack.Bot.start_link(Bot, %{}, "token", %{client: Stubs.Xlack.WebsocketClient})

    Application.put_env(:xlack, :rtm_module, original_slack_rtm)
  end
end
