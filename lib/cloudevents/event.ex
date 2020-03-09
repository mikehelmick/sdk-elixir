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
    :time,
    specversion: "1.0",
    extensions: %{}
  ]

  use Accessible

  @doc """
  Returns a new, uninitialized `%CloudEvents.Event{}` struct.
  """
  @spec new() :: %CloudEvents.Event{}
  def new(), do: %CloudEvents.Event{}

  @doc """
  Returns the the CloudEvents `id` attribute for this event.
  """
  @spec id(%CloudEvents.Event{}) :: String.t()
  def id(%CloudEvents.Event{id: id}), do: id

  @doc """
  Modifies the passed in CloudEvent to have the new specified `id` attribute.
  """
  @spec with_id(%CloudEvents.Event{}, String.t()) :: %CloudEvents.Event{}
  def with_id(event, id), do: %{event | id: id}

  @doc """
  Returns the CloudEvents `source` attribute as a string.
  """
  @spec source(%CloudEvents.Event{}) :: String.t()
  def source(%CloudEvents.Event{source: source}), do: source

  def with_source(event, source) when is_map(source) do
    source_str = URI.to_string(source)
    %{event | source: source_str}
  end

  def with_source(event, source), do: %{event | source: source}

  @doc """
  Returns the CloudEvents `source` attribute as a parsed %URI
  """
  @spec source_uri(%CloudEvents.Event{}) :: %URI{}
  def source_uri(%CloudEvents.Event{source: source}), do: URI.parse(source)

  @doc """
  Returns the CloudEvents `type` attribute.
  """
  @spec type(%CloudEvents.Event{}) :: String.t()
  def type(%CloudEvents.Event{type: type}), do: type

  @spec with_type(%CloudEvents.Event{}, String.t()) :: %CloudEvents.Event{}
  def with_type(event, type), do: %{event | type: type}

  @doc """
  Returns the CloudEvents `datacontent` attribute.
  If this attribute is not present, nil is returned.
  """
  @spec datacontenttype(%CloudEvents.Event{}) :: nil | String.t()
  def datacontenttype(%CloudEvents.Event{datacontenttype: dct}), do: dct

  @spec with_datacontenttype(%CloudEvents.Event{}, String.t()) :: %CloudEvents.Event{}
  def with_datacontenttype(event, dct), do: %{event | datacontenttype: dct}

  @doc """
  Returns the CloudEvents `datacontenttype` attribute as parsed by
  `ContentType.content_type`
  """
  @spec content_type(%CloudEvents.Event{}) ::
          {:ok, type :: binary, subtype :: binary, ContentType.params()} | :error
  def content_type(%CloudEvents.Event{datacontenttype: dct}) do
    ContentType.content_type(dct)
  end

  @doc """
  Returns the CloudEvents `schema` sttribute as a string.
  """
  @spec dataschema(%CloudEvents.Event{}) :: String.t()
  def dataschema(%CloudEvents.Event{dataschema: schema}), do: schema

  @spec with_dataschema(%CloudEvents.Event{}, String.t()) :: %CloudEvents.Event{}
  def with_dataschema(event, dataschema), do: %{event | dataschema: dataschema}

  @doc """
  Returns the CloudEvents `dataschema` attribute as a parsed `%URI{}`
  """
  @spec dataschema_uri(%CloudEvents.Event{}) :: %URI{}
  def dataschema_uri(%CloudEvents.Event{dataschema: schema}), do: URI.parse(schema)

  def subject(%CloudEvents.Event{subject: subject}), do: subject

  def with_subject(event, subject), do: %{event | subject: subject}

  def time(%CloudEvents.Event{time: time}), do: time

  def datetime(%CloudEvents.Event{time: time}) do
    case DateTime.from_iso8601(time) do
      {:ok, dt, _} -> {:ok, dt}
      {:error, reason} -> {:error, reason}
    end
  end

  def with_time(event, dt), do: %{event | time: DateTime.to_iso8601(dt)}

  def with_time_now(event) do
    %{event | time: DateTime.to_iso8601(DateTime.utc_now())}
  end

  @doc """
  Returns an extension attribute by key. All extensions are returned as their
  `String.t()` representation. `nil` is returned if the extension attribute
  is not present.
  """
  @spec get_extension(%CloudEvents.Event{}, String.t()) :: nil | String.t()
  def get_extension(%CloudEvents.Event{extensions: ext}, key) do
    Map.get(ext, key)
  end

  def with_extension(event = %CloudEvents.Event{extensions: ext}, extension, value) do
    if valid_extension?(extension) do
      if String.valid?(value) do
        %{event | extensions: Map.put(ext, extension, value)}
      else
        {:error, "Invalid extension attribute value, must be a string"}
      end
    else
      {:error, "Invalid extension attribute name"}
    end
  end

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
      |> validate_dataschema(event)
      |> validate_subject(event)

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

  defp valid_extension?(ext) when is_nil(ext), do: false

  defp valid_extension?(ext) do
    if String.valid?(ext) do
      String.match?("test123A", ~r/^([[:lower:]]|[[:digit:]])+$/u)
    else
      false
    end
  end

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

  defp validate_datacontenttype(errors, %CloudEvents.Event{datacontenttype: dct})
       when is_nil(dct) do
    errors
  end

  defp validate_datacontenttype(errors, %CloudEvents.Event{datacontenttype: dct}) do
    if !String.valid?(dct) || !valid_contenttype?(dct) do
      errors ++
        ["CloudEvents attribute `datacontenttype` must be a valid RFC 2046 string if present."]
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

  defp validate_dataschema(errors, %CloudEvents.Event{dataschema: schema}) when is_nil(schema) do
    errors
  end

  defp validate_dataschema(errors, %CloudEvents.Event{dataschema: schema}) do
    validate_string(
      errors,
      schema,
      "CloudEvents attribute `dataschema`, if present, must be a non-empty URI string"
    )
  end

  defp validate_subject(errors, %CloudEvents.Event{subject: subject}) when is_nil(subject) do
    errors
  end

  defp validate_subject(errors, %CloudEvents.Event{subject: subject}) do
    validate_string(
      errors,
      subject,
      "CloudEvents attribute `subject`, if present, must be a non-empty string"
    )
  end

  defp validate_string(errors, str, message) do
    if String.valid?(str) && String.length(str) > 0 do
      errors
    else
      errors ++ [message]
    end
  end
end
