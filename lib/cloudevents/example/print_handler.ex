defmodule CloudEvents.Example.PrintHandler do
  @behaviour CloudEvents.Handler

  def handle_event(event = %CloudEvents.Event{}, _) do
    IO.puts("Received CloudEvent: \n#{inspect(event)}\n----------\n")
    :ok
  end
end
