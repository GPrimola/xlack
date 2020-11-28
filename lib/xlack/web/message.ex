defmodule Xlack.Web.Message do
  defstruct [
    :text,
    :ts,
    :username,
    :channel,
    :bot_id,
    :client_msg_id,
    :team,
    :user,
    :subtype,
    :reactions,
    :permalink
  ]

  def new(%{"message" => slack_message, "channel" => channel}) do
    message =
      slack_message
      |> Enum.map(fn
        {key, value} when is_binary(key) ->
          {String.to_atom(key), value}

        key_value ->
          key_value
      end)
      |> Map.new()
      |> Map.merge(%{channel: channel})

    struct(__MODULE__, message)
  end

  def new(slack_message) do
    new(%{"message" => slack_message, "channel" => nil})
  end
end
