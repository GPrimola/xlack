defmodule Xlack.Web.Channel do
  defstruct [
    :id,
    :name,
    :name_normalized,
    :previous_names,
    :members,
    :purpose,
    :creator,
    :topic,
    :is_archived,
    :is_channel,
    :is_general,
    :is_member,
    :is_mpim,
    :is_org_shared,
    :is_private,
    :is_shared,
    :unlinked,
    :created
  ]

  def new(%{"purpose" => %{"value" => purpose}} = slack_channel) do
    slack_channel
    |> Map.put("purpose", purpose)
    |> new()
  end

  def new(slack_channel) when is_map(slack_channel) do
    channel =
      slack_channel
      |> Enum.map(fn
        {key, value} when is_binary(key) ->
          {String.to_atom(key), value}

        key_value ->
          key_value
      end)
      |> Map.new()

    struct(__MODULE__, channel)
  end

  def new(channel_id) do
    new(%{"id" => channel_id})
  end
end
