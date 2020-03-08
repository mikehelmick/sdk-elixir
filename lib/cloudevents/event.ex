defmodule CloudEvents.Event do
  @moduledoc """
  Module that defines a struct and functions for handling CloudEvents.

  Currently implements the 1.0 specversion of CloudEvents.
  https://github.com/cloudevents/spec/blob/v1.0/spec.md
  """

  @specversion "1.0"

  defstruct [
    :id,
    :source,
    :type,
    :datacontenttype,
    :data,
    :dataschema,
    :subject,
    specversion: "1.0",
    extensions: %{}
  ]

  def id(%CloudEvents.Event{id: id}), do: id
  def source(%CloudEvents.Event{source: source}), do: source
  def source_uri(%CloudEvents.Event{source: source}), do: URI.parse(source)

  @doc """
  Determines if a given `%Event{}` struct represents a valid CloudEvent.

  If the `%Event{}` is valid, `:ok` is returned, otherwise `{:error, reason}`
  is returned.
  """
  @spec validate(%CloudEvents.Event{}) :: :ok | {:error, [String.t()]}
  def validate(event) do
    errors =
      []
      |> validate_id(event)
      |> validate_source(event)
      |> validate_specversion(event)
      |> validate_type(event)
      |> validate_datacontenttype(event)

    case length(errors) do
      0 -> :ok
      _ -> {:error, errors}
    end
  end

  @doc """
  Simple true/false evaluation of if an `%Event{}` struct represents a valid
  CloudEvent. Speific error messages are not returned.
  """
  @spec valid?(%CloudEvents.Event{}) :: boolean()
  def valid?(event), do: :ok == validate(event)

  ## Internal methods for validation.

  defp validate_id(errors, %CloudEvents.Event{id: id}) when is_nil(id) do
    errors ++ ["CloudEvents attribute `id` must be present"]
  end

  defp validate_id(errors, %CloudEvents.Event{id: id}) do
    validate_string(errors, id, "CloudEvents attribute `id` must be a non-empty string")
  end

  defp validate_source(errors, %CloudEvents.Event{source: source}) when is_nil(source) do
    errors ++ ["CloudEvents attribute `source` must be present"]
  end

  defp validate_source(errors, %CloudEvents.Event{source: source}) do
    validate_string(errors, source, "CloudEvents attribute `source` must be a non-empty string")
  end

  defp validate_specversion(errors, %CloudEvents.Event{specversion: sv}) when is_nil(sv) do
    errors ++ ["CloudEvents attribute `specversion` must be present"]
  end

  defp validate_specversion(errors, %CloudEvents.Event{specversion: sv}) do
    if sv == @specversion do
      errors
    else
      errors ++ ["CloudEvents attribute `specversion` must have the value of `1.0`"]
    end
  end

  defp validate_type(errors, %CloudEvents.Event{type: type}) when is_nil(type) do
    errors ++ ["CloudEvents attribute `type` must be present"]
  end
  defp validate_type(errors, %CloudEvents.Event{type: type}) do
    validate_string(errors, type, "CloudEvents attribute `type` must be a non-empty string")
  end

  defp validate_datacontenttype(errors, %CloudEvents.Event{datacontenttype: dct}) when is_nil(dct) do
    errors
  end
  defp validate_datacontenttype(errors, %CloudEvents.Event{datacontenttype: dct}) do
    if !String.valid?(dct) || !valid_contenttype?(dct) do
      errors ++ ["CloudEvents attribute `datacontenttype` must be a valid RFC 2046 string if present."]
    else
      errors
    end
  end

  defp valid_contenttype?(content_type) do
    case ContentType.content_type(content_type) do
      {:ok, _, _, _} -> true
      _ -> false
    end
  end

  defp validate_string(errors, str, message) do
    if String.valid?(str) && String.length(str) > 0 do
      errors
    else
      errors ++ [message]
    end
  end
end
