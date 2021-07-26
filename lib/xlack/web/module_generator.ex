alias Xlack.Web.{Documentation, User, Message, Channel, Channels, Chat, Users}

module_namespace = Xlack.Web

Xlack.Web.get_documentation()
|> Enum.reject(fn {module, _functions} -> module in ~w(rtm) end)
|> Enum.each(fn {module_name, functions} ->
  module =
    module_name
    |> String.split(".")
    |> Enum.map(&Macro.camelize/1)
    |> Enum.reduce(module_namespace, &Module.concat(&2, &1))

  defmodule module do
    Enum.each(functions, fn doc ->
      function_name = doc.function

      arguments = Documentation.arguments(doc)
      argument_value_keyword_list = Documentation.arguments_with_values(doc)

      @doc """
      #{Documentation.to_doc_string(doc)}
      """
      def unquote(function_name)(unquote_splicing(arguments), optional_params \\ %{})

      if (module in [Channels, Chat] and function_name not in [:create, :join, :list]) or
           (module == Users and function_name in [:get_presence, :info]) do
        rest_args = Enum.drop(arguments, 1)

        def unquote(function_name)(%{id: id}, unquote_splicing(rest_args), optional_params) do
          unquote(function_name)(id, unquote_splicing(rest_args), optional_params)
        end
      end

      def unquote(function_name)(unquote_splicing(arguments), optional_params) do
        required_params = unquote(argument_value_keyword_list)

        url = Application.get_env(:xlack, :url, "https://slack.com")

        params =
          optional_params
          |> Map.to_list()
          |> Keyword.merge(required_params)
          |> Keyword.put_new(:token, get_token(optional_params))
          |> Enum.reject(fn {_, v} -> v == nil end)

        case perform!(
               "#{url}/api/#{unquote(doc.endpoint)}",
               params(unquote(function_name), params, unquote(arguments))
             ) do
          %{"ok" => false, "error" => message} ->
            {:error, message}

          %{"channel" => _slack_channel, "message" => _slack_message} = msg ->
            {:ok, Message.new(msg)}

          %{"channel" => slack_channel} ->
            {:ok, Channel.new(slack_channel)}

          %{"channels" => slack_channels} ->
            {:ok, Enum.map(slack_channels, &Channel.new/1)}

          %{"message" => slack_message} ->
            {:ok, Message.new(slack_message)}

          %{"messages" => slack_messages} ->
            {:ok, Enum.map(slack_messages, &Message.new/1)}

          %{"user" => slack_user} ->
            {:ok, User.new(slack_user)}

          %{"users" => slack_users} ->
            {:ok, Enum.map(slack_users, &User.new/1)}

          %{"members" => slack_users} ->
            {:ok, Enum.map(slack_users, &User.new/1)}

          response ->
            response
        end
      end
    end)

    defp perform!(url, body) do
      Application.get_env(:xlack, :web_http_client, Xlack.Web.DefaultClient).post!(url, body)
    end

    defp get_token(%{token: token}), do: token
    defp get_token(_), do: Application.get_env(:xlack, :api_token)

    defp params(:upload, params, arguments) do
      file = List.first(arguments)

      params =
        Enum.map(params, fn {key, value} ->
          {"", to_string(value), {"form-data", [{"name", key}]}, []}
        end)

      {:multipart, params ++ [{:file, file, []}]}
    end

    defp params(_, params, _), do: {:form, params}
  end
end)
