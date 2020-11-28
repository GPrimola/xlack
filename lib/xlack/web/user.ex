defmodule Xlack.Web.User do
  defstruct [
    :id,
    :name,
    :email,
    :phone,
    :real_name,
    :last_name,
    :first_name,
    :real_name_normalized,
    :display_name,
    :display_name_normalized,
    :skype,
    :color,
    :deleted,
    :fields,
    :avatar_hash,
    :image_1024,
    :image_192,
    :image_24,
    :image_32,
    :image_48,
    :image_512,
    :image_72,
    :image_original,
    :is_admin,
    :is_app_user,
    :is_bot,
    :is_custom_image,
    :is_owner,
    :is_primary_owner,
    :is_restricted,
    :is_ultra_restricted,
    :status_emoji,
    :status_expiration,
    :status_text,
    :status_text_canonical,
    :team,
    :team_id,
    :title,
    :tz,
    :tz_label,
    :tz_offset,
    :updated
  ]

  def new(%{"profile" => slack_profile} = slack_user) do
    user =
      slack_user
      |> Enum.map(fn
        {key, value} when is_binary(key) ->
          {String.to_atom(key), value}

        key_value ->
          key_value
      end)
      |> Map.new()
      |> Map.drop([:profile])

    profile =
      Enum.map(slack_profile, fn {key, value} -> {String.to_atom(key), value} end) |> Map.new()

    struct(__MODULE__, Map.merge(user, profile))
  end
end
