defmodule Xlack.Factory do
  use ExMachina

  def conversations_list_factory do
    %{
      "created" => 1_408_433_880,
      "creator" => "U02GCFTGS",
      "id" => "C02GCFTGY",
      "is_archived" => false,
      "is_channel" => true,
      "is_ext_shared" => false,
      "is_general" => true,
      "is_group" => false,
      "is_im" => false,
      "is_member" => false,
      "is_mpim" => false,
      "is_org_shared" => false,
      "is_pending_ext_shared" => false,
      "is_private" => false,
      "is_shared" => false,
      "name" => "announcements",
      "name_normalized" => "announcements",
      "num_members" => 2502,
      "parent_conversation" => nil,
      "pending_connected_team_ids" => [],
      "pending_shared" => [],
      "previous_names" => ["general"],
      "purpose" => %{
        "creator" => "U010YF14VRU",
        "last_set" => 1_605_079_733,
        "value" =>
          "This channel is for team-wide communication and announcements. All team members are in this channel. You can post fun stuff in the <#C02GCFTH0|random> channel."
      },
      "shared_team_ids" => ["T02GCFTGQ"],
      "topic" => %{
        "creator" => "U778BQJNA",
        "last_set" => 1_592_219_024,
        "value" =>
          "This channel is for important company announcements only. Your message will be sent to ~2260 people. Think whether they all must know what you’re about to send before hitting the enter key. Thank you."
      },
      "unlinked" => 0
    }
  end
end
