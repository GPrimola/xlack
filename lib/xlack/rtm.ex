defmodule Xlack.JsonDecodeError do
  @moduledoc false

  defexception [:reason, :string]

  def message(%Xlack.JsonDecodeError{reason: reason, string: string}) do
    "Poison could not decode string for reason: `:#{reason}`, string given:\n#{string}"
  end
end

defmodule Xlack.Rtm do
  @moduledoc false

  def start(token) do
    with url <- slack_url(token),
         headers <- [],
         options <- Application.get_env(:xlack, :web_http_client_opts, []) do
      url
      |> HTTPoison.get(headers, options)
      |> handle_response()
    end
  end

  defp handle_response({:ok, %HTTPoison.Response{body: body}}) do
    case Jason.decode!(body, keys: :atoms) do
      %{ok: true} = json ->
        {:ok, json}

      %{error: reason} ->
        {:error, "Xlack API returned an error `#{reason}.\n Response: #{body}"}

      _ ->
        {:error, "Invalid RTM response"}
    end
  rescue
    error in Jason.DecodeError ->
      %Jason.DecodeError{data: reason, position: _, token: _} = error
      {:error, %Xlack.JsonDecodeError{reason: reason, string: body}}
  end

  defp handle_response(error), do: error

  defp slack_url(token) do
    Application.get_env(:xlack, :url, "https://slack.com") <>
      "/api/rtm.start?token=#{token}&batch_presence_aware=true&presence_sub=true"
  end
end
