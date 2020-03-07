defmodule CloudEvents.EventTest do

  use ExUnit.Case, async: true

  test "missing id" do
    event = %CloudEvents.Event{specversion: "1.0", source: "foo", type: "bar"}
    {:error, [message]} = CloudEvents.Event.validate(event)
    assert message == "CloudEvents attribute `id` must be present"
  end


end
