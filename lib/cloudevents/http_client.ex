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
              headers =
                Map.new()
                |> Map.put("Content-Type", "application/cloudevents+json")

              # Transform struct for safe encoding.
              ext = extensions(event)

              eventMap =
                Map.delete(event, :encoding_fn)
                |> Map.delete(:__struct__)
                |> Map.delete(:extensions)

              eventMap =
                List.foldl(Map.to_list(ext), eventMap, fn {k, v}, m -> Map.put(m, k, v) end)

              {:ok, body} = Poison.encode(eventMap)
              {headers, body}

            _ ->
              # binary encoding is the default encoding.
              headers =
                Map.new()
                |> Map.put("ce-id", id(event))
                |> Map.put("ce-source", source(event))
                |> Map.put("ce-type", type(event))
                |> Map.put("ce-specversion", specversion(event))
                |> add_contenttype(event)
                |> add_schema(event)
                |> add_subject(event)
                |> add_time(event)
                |> add_extensions(event)

              body = data_encoded(event)
              {headers, body}
          end

        case HTTPoison.put(url, body, headers) do
          {:ok, response} -> {:ok, response}
          {:error, err} -> {:error, err}
        end
    end
  end

  def add_contenttype(h, %CloudEvents.Event{datacontenttype: dct}) when is_nil(dct), do: h

  def add_contenttype(h, %CloudEvents.Event{datacontenttype: dct}) do
    Map.put(h, "Content-Type", dct)
  end

  def add_schema(h, %CloudEvents.Event{dataschema: schema}) when is_nil(schema), do: h

  def add_schema(h, %CloudEvents.Event{dataschema: schema}) do
    Map.put(h, "ce-dataschema", schema)
  end

  def add_subject(h, %CloudEvents.Event{subject: subject}) when is_nil(subject), do: h

  def add_subject(h, %CloudEvents.Event{subject: subject}) do
    Map.put(h, "ce-subject", subject)
  end

  def add_time(h, %CloudEvents.Event{time: time}) when is_nil(time), do: h

  def add_time(h, %CloudEvents.Event{time: time}) do
    Map.put(h, "ce-time", time)
  end

  def add_extensions(h, []), do: h

  def add_extensions(h, [{k, v} | rest]) do
    add_extensions(Map.put(h, "ce-#{k}", v), rest)
  end

  def add_extensions(h, %CloudEvents.Event{extensions: ext}) do
    add_extensions(h, Map.to_list(ext))
  end
end
