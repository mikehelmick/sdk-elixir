defmodule CloudEvents.HTTPClient do
  import CloudEvents.Event

  def send(url, event) do
    case validate(event) do
      {:error, errors} ->
        {:error, errors}

      :ok ->
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

        case HTTPoison.post(url, body, headers) do
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
