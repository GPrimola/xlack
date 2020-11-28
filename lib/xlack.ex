defmodule Xlack do
  @moduledoc """
  Xlack is a genserver-ish interface for working with the Xlack real time
  messaging API through a Websocket connection.

  To use this module you'll need a need a Xlack API token which can be retrieved
  by following the [Token Generation Instructions] or by creating a new [bot
  integration].

  [Token Generation Instructions]: https://hexdocs.pm/slack/token_generation_instructions.html
  [bot integration]: https://api.slack.com/bot-users

  ## Example

  ```
  defmodule Bot do
    use Xlack

    def handle_event(message = %{type: "message"}, slack, state) do
      if message.text == "Hi" do
        send_message("Hello to you too!", message.channel, slack)
      end

      {:ok, state}
    end
    def handle_event(_, _, state), do: {:ok, state}
  end

  Xlack.Bot.start_link(Bot, [], "API_TOKEN")
  ```

  `handle_*` methods are always passed `slack` and `state` arguments. The
  `slack` argument holds the state of Xlack and is kept up to date
  automatically.

  In this example we're just matching against the message type and checking if
  the text content is "Hi" and if so, we reply with our own greeting.

  The message type is pattern matched against because the
  [Xlack RTM API](https://api.slack.com/rtm) defines many different types of
  messages that we can receive. Because of this it's wise to write a catch-all
  `handle_event/3` in your bots to prevent crashing.

  ## Callbacks

  * `handle_connect(slack, state)` - called when connected to Xlack.
  * `handle_event(message, slack, state)` - called when a message is received.
  * `handle_close(reason, slack, state)` - called when websocket is closed before process is terminated.
  * `handle_info(message, slack, state)` - called when any other message is received in the process mailbox.

  ## Xlack argument

  The Xlack argument that's passed to each callback is what contains all of the
  state related to Xlack including a list of channels, users, groups, bots, and
  even the socket.

  Here's a list of what's stored:

  * me - The current bot/users information stored as a map of properties.
  * team - The current team's information stored as a map of properties.
  * bots - Stored as a map with id's as keys.
  * channels - Stored as a map with id's as keys.
  * groups - Stored as a map with id's as keys.
  * users - Stored as a map with id's as keys.
  * ims (direct message channels) - Stored as a map with id's as keys.
  * socket - The connection to Xlack.
  * client - The client that makes calls to Xlack.

  For all but `socket` and `client`, you can see what types of data to expect each of the
  types to contain from the [Xlack API types] page.

  [Xlack API types]: https://api.slack.com/types
  """

  alias Xlack.Web.{Channel, Message, User}

  def conversations(opts \\ %{}),
    do: Xlack.Web.Conversations.list(opts)

  def send_message(channel_or_user, text, opts \\ %{})

  def send_message(%Channel{id: channel}, text, opts),
    do: send_message(channel, text, opts)

  def send_message("C" <> _cid = channel, text, opts),
    do: Xlack.Web.Chat.post_message(channel, text, opts)

  def send_message(%User{id: user}, text, opts) do
    send_message(user, text, opts)
  end

  def send_message("U" <> _uid = user, text, opts) do
    with {:ok, channel} <- Xlack.Web.Im.open(user, opts),
         do: send_message(channel, text, opts)
  end

  def send_message(%Message{channel: channel, text: text}) when not is_nil(channel),
    do: send_message(channel, text)

  def send_message(%Message{user: user, text: text}),
    do: send_message(user, text)

  def delete(%Message{channel: channel, ts: ts}, opts \\ %{}),
    do: Xlack.Web.Chat.delete(channel, ts, opts)

  def info(channel_or_user, opts \\ %{})

  def info(%Channel{id: channel}, opts),
    do: info(channel, opts)

  def info("C" <> _cid = channel, opts),
    do: Xlack.Web.Channels.info(channel, opts)

  def info(%User{id: user}, opts),
    do: info(user, opts)

  def info("U" <> _uid = user, opts),
    do: Xlack.Web.Users.info(user, opts)

  def history(channel, opts \\ %{})

  def history(%Channel{id: channel}, opts),
    do: history(channel, opts)

  def history("C" <> _cid = channel, opts),
    do: Xlack.Web.Channels.history(channel, opts)

  defmacro __using__(_) do
    quote do
      import Xlack.Lookups
      import Xlack.Sends

      def handle_connect(_slack, state), do: {:ok, state}
      def handle_event(_message, _slack, state), do: {:ok, state}
      def handle_close(_reason, _slack, state), do: :close
      def handle_info(_message, _slack, state), do: {:ok, state}

      def child_spec(_opts) do
        %{
          id: __MODULE__,
          start: {__MODULE__, :start_link, []},
          type: :worker,
          restart: :permanent,
          shutdown: 500
        }
      end

      defoverridable handle_connect: 2,
                     handle_event: 3,
                     handle_close: 3,
                     handle_info: 3,
                     child_spec: 1
    end
  end
end
