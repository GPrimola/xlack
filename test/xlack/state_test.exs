defmodule Xlack.StateTest do
  use ExUnit.Case
  alias Xlack.State

  test "channel_joined sets is_member to true" do
    new_slack =
      State.update(
        %{type: "channel_joined", channel: %{id: "123", members: ["123456", "654321"]}},
        slack()
      )

    assert new_slack.channels["123"].is_member == true
    assert new_slack.channels["123"].members == ["123456", "654321"]
  end

  test "channel_left sets is_member to false" do
    new_slack =
      State.update(
        %{type: "channel_left", channel: "123"},
        slack()
      )

    assert new_slack.channels["123"].is_member == false
  end

  test "channel_rename renames the channel" do
    new_slack =
      State.update(
        %{type: "channel_rename", channel: %{id: "123", name: "bar"}},
        slack()
      )

    assert new_slack.channels["123"].name == "bar"
  end

  test "channel_archive marks channel as archived" do
    new_slack =
      State.update(
        %{type: "channel_archive", channel: "123"},
        slack()
      )

    assert new_slack.channels["123"].is_archived == true
  end

  test "channel_unarchive marks channel as not archived" do
    new_slack =
      State.update(
        %{type: "channel_unarchive", channel: "123"},
        slack()
      )

    assert new_slack.channels["123"].is_archived == false
  end

  test "channel_leave marks channel as not archived" do
    new_slack =
      State.update(
        %{type: "channel_unarchive", channel: "123"},
        slack()
      )

    assert new_slack.channels["123"].is_archived == false
  end

  test "team_rename renames team" do
    new_slack =
      State.update(
        %{type: "team_rename", name: "Bar"},
        slack()
      )

    assert new_slack.team.name == "Bar"
  end

  test "team_join adds user to users" do
    user_length = map_size(slack().users)

    new_slack =
      State.update(
        %{type: "team_join", user: %{id: "345"}},
        slack()
      )

    assert map_size(new_slack.users) == user_length + 1
  end

  test "user_change updates user" do
    new_slack =
      State.update(
        %{type: "user_change", user: %{id: "123", name: "bar"}},
        slack()
      )

    assert new_slack.users["123"].name == "bar"
    assert new_slack.users["123"].presence == "active"
  end

  test "bot_added adds bot to bots" do
    bot_length = map_size(slack().bots)

    new_slack =
      State.update(
        %{type: "bot_added", bot: %{id: "345", name: "new"}},
        slack()
      )

    assert map_size(new_slack.bots) == bot_length + 1
  end

  test "bot_changed updates bot in bots" do
    new_slack =
      State.update(
        %{type: "bot_changed", bot: %{id: "123", name: "new"}},
        slack()
      )

    assert new_slack.bots["123"].name == "new"
  end

  test "channel_join message should add member" do
    new_slack =
      State.update(
        %{type: "message", subtype: "channel_join", user: "U456", channel: "123"},
        slack()
      )

    assert new_slack.channels["123"].members |> Enum.sort() == ["U123", "U456"]
  end

  test "channel_leave message should remove member" do
    new_slack =
      State.update(
        %{type: "message", subtype: "channel_leave", user: "U123", channel: "123"},
        slack()
      )

    assert new_slack.channels["123"].members == []
  end

  test "presence_change message should update user" do
    new_slack =
      State.update(
        %{presence: "testing", type: "presence_change", user: "123"},
        slack()
      )

    assert new_slack.users["123"].presence == "testing"
  end

  test "bulk presence_change message should update users" do
    new_slack =
      State.update(
        %{presence: "testing", type: "presence_change", users: ["123", "U2"]},
        slack()
      )

    assert new_slack.users["123"].presence == "testing"
    assert new_slack.users["U2"].presence == "testing"
  end

  test "group_joined event should add group" do
    new_slack =
      State.update(
        %{type: "group_joined", channel: %{id: "G123", members: ["U123", "U456"]}},
        slack()
      )

    assert new_slack.groups["G123"]
    assert new_slack.groups["G123"].members == ["U123", "U456"]
  end

  test "group_topic message should change topic" do
    new_slack =
      State.update(
        %{
          type: "message",
          subtype: "group_topic",
          channel: "G000",
          user: "U000",
          topic: "NewTopic"
        },
        slack()
      )

    assert new_slack.groups["G000"][:topic][:value] == "NewTopic"
  end

  test "channel_topic message should change topic" do
    new_slack =
      State.update(
        %{
          type: "message",
          subtype: "channel_topic",
          channel: "123",
          user: "U000",
          topic: "NewTopic"
        },
        slack()
      )

    assert new_slack.channels["123"][:topic][:value] == "NewTopic"
  end

  test "group_join message should add user to member list" do
    new_slack =
      State.update(
        %{type: "message", subtype: "group_join", channel: "G000", user: "U000"},
        slack()
      )

    assert Enum.member?(new_slack.groups["G000"][:members], "U000")
  end

  test "group_leave message should remove user from member list" do
    new_slack =
      State.update(
        %{type: "message", subtype: "group_leave", channel: "G000", user: "U111"},
        slack()
      )

    refute Enum.member?(new_slack.groups["G000"].members, "U111")
  end

  test "group_left message should remove group altogether" do
    new_slack =
      State.update(
        %{type: "group_left", channel: "G000"},
        slack()
      )

    refute new_slack.groups["G000"]
  end

  test "im_created message should add direct message channel to list" do
    channel = %{name: "channel", id: "C456"}

    new_slack =
      State.update(
        %{type: "im_created", channel: channel},
        slack()
      )

    assert new_slack.ims == %{"C456" => channel}
  end

  test "user_change merges an existing user" do
    user = %{id: "123", presence: "away", nickname: "Baz"}

    new_slack =
      State.update(
        %{type: "user_change", user: user},
        slack()
      )

    assert new_slack.users["123"] == %{
             id: "123",
             name: "Bar",
             presence: "away",
             nickname: "Baz"
           }
  end

  test "user_change adds a new user" do
    user = %{id: "345", presence: "active", name: "Bar"}

    new_slack =
      State.update(
        %{type: "user_change", user: user},
        slack()
      )

    assert new_slack.users["345"] == %{
             id: "345",
             name: "Bar",
             presence: "active"
           }
  end

  defp slack do
    %{
      channels: %{
        "123" => %{
          id: 123,
          name: "foo",
          is_member: nil,
          is_archived: nil,
          members: ["U123"],
          topic: %{value: "topic"}
        }
      },
      team: %{
        name: "Foo"
      },
      users: %{
        "123" => %{
          name: "Bar",
          presence: "active"
        },
        "U2" => %{
          name: "Baz",
          presence: "away"
        }
      },
      groups: %{
        "G000" => %{
          name: "secret-group",
          members: ["U111", "U222"],
          topic: %{value: "topic"}
        }
      },
      bots: %{
        "123" => %{
          name: "Bot"
        }
      },
      ims: %{}
    }
  end
end
