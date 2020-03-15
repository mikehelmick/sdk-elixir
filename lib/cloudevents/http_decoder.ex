defmodule CloudEvents.HTTPDecoder do
  import CloudEvents.Event

  def decode(headers, body) do
    case binary(headers, body) do
      {:error, _} ->
        structured(headers, body)

      {:ok, event} ->
        {:ok, event}
    end
  end

  def structured(_headers, _body) do
    {:error, :not_implemented}
  end

  def binary(headers, body) do
    if headers["ce-type"] == nil || headers["ce-source"] == nil ||
         headers["ce-type"] == nil || headers["ce-specversion"] == nil do
      {:error, :not_binary_cloudevent}
    else
      {event, headers} =
        {CloudEvents.Event.new(), headers}
        |> bin_add_id()
        |> bin_add_source()
        |> bin_add_type()
        |> bin_add_specversion()
        |> bin_add_contenttype()
        |> bin_add_schema()
        |> bin_add_subject()
        |> bin_add_time()

      event = bin_add_extensions(event, Map.to_list(headers))

      # Set the data to be the content of the body or, if application/json
      # assist with decoding it.
      event =
        case datacontenttype(event) do
          "application/json" ->
            with_data(event, CloudEvents.Encoding.json_decode(body))
            |> with_data_json_encoding()

          _ ->
            with_data(event, body)
        end

      {:ok, event}
    end
  end

  defp bin_add_id({event, headers}) do
    {event |> with_id(headers["ce-id"]), Map.delete(headers, "ce-id")}
  end

  defp bin_add_source({event, headers}) do
    {event |> with_source(headers["ce-source"]), Map.delete(headers, "ce-source")}
  end

  defp bin_add_type({event, headers}) do
    {event |> with_type(headers["ce-type"]), Map.delete(headers, "ce-type")}
  end

  defp bin_add_specversion({event, headers}) do
    {event |> with_specversion(headers["ce-specversion"]), Map.delete(headers, "ce-specversion")}
  end

  def bin_add_extensions(event, []), do: event

  def bin_add_extensions(event, [{key, value} | rest]) do
    if String.starts_with?(key, "ce-") do
      bin_add_extensions(
        with_extension(event, String.trim_leading(key, "ce-"), value),
        rest
      )
    else
      bin_add_extensions(event, rest)
    end
  end

  defp bin_add_optional({event, headers}, header, function) do
    case headers[header] do
      nil ->
        {event, headers}

      data ->
        {function.(event, data), Map.delete(headers, header)}
    end
  end

  defp bin_add_contenttype({event, headers}) do
    bin_add_optional(
      {event, headers},
      "content-type",
      fn event, data -> with_datacontenttype(event, data) end
    )
  end

  defp bin_add_schema({event, headers}) do
    bin_add_optional(
      {event, headers},
      "ce-dataschema",
      fn event, data -> with_dataschema(event, data) end
    )
  end

  defp bin_add_subject({event, headers}) do
    bin_add_optional(
      {event, headers},
      "ce-subject",
      fn event, data -> with_subject(event, data) end
    )
  end

  defp bin_add_time({event, headers}) do
    bin_add_optional(
      {event, headers},
      "ce-time",
      fn event, data ->
        case DateTime.from_iso8601(data) do
          {:ok, time, _} -> with_time(event, time)
          _ -> event
        end
      end
    )
  end
end
