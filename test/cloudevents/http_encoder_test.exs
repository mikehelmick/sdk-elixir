defmodule CloudEvents.HTTPEncoderTest do
  use ExUnit.Case, async: true

  import CloudEvents.Event

  test "minimal structured" do
    event =
      CloudEvents.Event.new()
      |> with_id("1")
      |> with_source("/path/of/source")
      |> with_type("com.example.stuff")

    {headers, body} = CloudEvents.HTTPEncoder.structured(event)

    assert 1 == length(Map.keys(headers))
    assert "application/cloudevents+json" = Map.get(headers, "Content-Type")

    {:ok, decoded} = Poison.decode(body)
    assert 4 == length(Map.keys(decoded))
    assert "1" == decoded["id"]
    assert "/path/of/source" == decoded["source"]
    assert "com.example.stuff" == decoded["type"]
    assert "1.0" == decoded["specversion"]
  end

  test "minimal binary" do
    event =
      CloudEvents.Event.new()
      |> with_id("1")
      |> with_source("/path/of/source")
      |> with_type("com.example.stuff")

    {headers, body} = CloudEvents.HTTPEncoder.binary(event)

    assert nil == body
    assert 4 == length(Map.keys(headers))
    assert "1" == headers["ce-id"]
    assert "/path/of/source" == headers["ce-source"]
    assert "com.example.stuff" == headers["ce-type"]
    assert "1.0" == headers["ce-specversion"]
  end
end
