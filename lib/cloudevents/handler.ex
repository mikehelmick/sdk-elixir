defmodule CloudEvents.Handler do
  @callback handle_event(%CloudEvents.Event{}, List.t()) ::
              :ok | {:reply, CloudEvent.Event} | {:error, String.t()}
end
