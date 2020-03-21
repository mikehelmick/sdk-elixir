defmodule CloudEvents.Example.TransformHandler do
  @moduledoc """
  Example CloudEvents handler that receives an event and replies
  with a new event. The new event will be the same
  as the input, except the type will have ".reply" added to the end
  and a new extension that says where it came from.
  """
  @behaviour CloudEvents.Handler

  def handle_event(event = %CloudEvents.Event{}, _) do
    IO.puts("Received CloudEvent: \n#{inspect(event)}\n----------\n")
    reply_event = event
      |> CloudEvents.Event.with_type("#{event.type}.reply")
      |> CloudEvents.Event.with_extension("handler", "#{__MODULE__}")
      |> CloudEvents.Event.with_time_now()
    IO.puts("Replying with CloudEvent: \n#{inspect(reply_event)}")
    {:reply, reply_event}
  end
end
