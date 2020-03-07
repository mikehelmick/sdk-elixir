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

  @doc """
  Determines if a given `%Event{}` struct represents a valid CloudEvent.

  If the `%Event{}` is valid, `:ok` is returned, otherwise `{:error, reason}`
  is returned.
  """
  @spec validate(%CloudEvents.Event{}) :: :ok | {:error, [String.t()]}
  def validate(event) do
    errors = [] |>
      validate_id(event)

    case length(errors) do
      0 -> :ok
      _ -> {:error, errors}
    end
  end

  defp validate_id(errors, %CloudEvents.Event{id: id}) when is_nil(id) do
    errors ++ ["CloudEvents attribute `id` must be present"]
  end
  defp validate_id(errors, %CloudEvents.Event{id: id}) do
    if String.valid?(id) && String.length(id) > 0 do
      errors
    else
      errors ++ ["CloudEvents attribute `id` must be a non-empty string"]
    end
  end
end
