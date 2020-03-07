defmodule CloudeventsTest do
  use ExUnit.Case
  doctest Cloudevents

  test "greets the world" do
    assert Cloudevents.hello() == :world
  end
end
