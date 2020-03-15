defmodule CloudEvents.HTTPClient do
  import CloudEvents.Event

  def send(url, event, options \\ []) do
    encoding = Keyword.get(options, :encoding, :binary)

    case validate(event) do
      {:error, errors} ->
        {:error, errors}

      :ok ->
        {headers, body} =
          case encoding do
            :structured ->
              CloudEvents.HTTPEncoder.structured(event)

            _ ->
              CloudEvents.HTTPEncoder.binary(event)
          end

        headers = Map.put(headers, "user-agent", "cloudevents/sdk-elixir")

        case HTTPoison.put(url, body, headers) do
          {:ok, response} -> {:ok, response}
          {:error, err} -> {:error, err}
        end
    end
  end
end
