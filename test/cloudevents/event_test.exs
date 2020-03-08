defmodule CloudEvents.EventTest do
  use ExUnit.Case, async: true

  test "missing id" do
    event = %CloudEvents.Event{specversion: "1.0", source: "foo", type: "bar"}
    {:error, [message]} = CloudEvents.Event.validate(event)
    assert message == "CloudEvents attribute `id` must be present"
  end

  test "invalid id, empty string" do
    event = %CloudEvents.Event{id: "", specversion: "1.0", source: "foo", type: "bar"}
    {:error, [message]} = CloudEvents.Event.validate(event)
    assert message == "CloudEvents attribute `id` must be a non-empty string"
  end

  test "invalid id, non string" do
    event = %CloudEvents.Event{id: 42, specversion: "1.0", source: "foo", type: "bar"}
    {:error, [message]} = CloudEvents.Event.validate(event)
    assert message == "CloudEvents attribute `id` must be a non-empty string"
  end

  test "missing source" do
    event = %CloudEvents.Event{specversion: "1.0", id: "1", type: "bar"}
    {:error, [message]} = CloudEvents.Event.validate(event)
    assert message == "CloudEvents attribute `source` must be present"
  end

  test "invalid source, empty string" do
    event = %CloudEvents.Event{id: "1", specversion: "1.0", source: "", type: "bar"}
    {:error, [message]} = CloudEvents.Event.validate(event)
    assert message == "CloudEvents attribute `source` must be a non-empty string"
  end

  test "invalid source, non string" do
    event = %CloudEvents.Event{id: "42", specversion: "1.0", source: :test, type: "bar"}
    {:error, [message]} = CloudEvents.Event.validate(event)
    assert message == "CloudEvents attribute `source` must be a non-empty string"
  end

  test "missing specversion" do
    event = %CloudEvents.Event{id: "1", source: "foo", type: "bar", specversion: nil}
    {:error, [message]} = CloudEvents.Event.validate(event)
    assert message == "CloudEvents attribute `specversion` must be present"
  end

  test "invalid specversion, empty string" do
    event = %CloudEvents.Event{id: "42", specversion: "", source: "http://test", type: "bar"}
    {:error, [message]} = CloudEvents.Event.validate(event)
    assert message == "CloudEvents attribute `specversion` must have the value of `1.0`"
  end

  test "invalid specversion, wrong version" do
    event = %CloudEvents.Event{id: "42", specversion: "0.3", source: "http://test", type: "bar"}
    {:error, [message]} = CloudEvents.Event.validate(event)
    assert message == "CloudEvents attribute `specversion` must have the value of `1.0`"
  end

  test "missing type" do
    event = %CloudEvents.Event{id: "42", specversion: "1.0", source: "foo"}
    {:error, [message]} = CloudEvents.Event.validate(event)
    assert message == "CloudEvents attribute `type` must be present"
  end

  test "invalid type, empty string" do
    event = %CloudEvents.Event{id: "42", specversion: "1.0", source: "foo", type: ""}
    {:error, [message]} = CloudEvents.Event.validate(event)
    assert message == "CloudEvents attribute `type` must be a non-empty string"
  end

  test "invalid type, non string" do
    event = %CloudEvents.Event{id: "42", specversion: "1.0", source: "foo", type: :bar}
    {:error, [message]} = CloudEvents.Event.validate(event)
    assert message == "CloudEvents attribute `type` must be a non-empty string"
  end

  test "invalid datacontenttype" do
    event = %CloudEvents.Event{
      id: "42", specversion: "1.0", source: "foo", type: "bar", datacontenttype: "bar baz"}
    {:error, [message]} = CloudEvents.Event.validate(event)
    assert message == "CloudEvents attribute `datacontenttype` must be a valid RFC 2046 string if present."
  end

  test "valid json datacontenttype" do
    event = %CloudEvents.Event{
      id: "42", specversion: "1.0", source: "foo", type: "bar", datacontenttype: "application/json"}
    assert :ok == CloudEvents.Event.validate(event)
  end

  test "valid xml datacontenttype" do
    event = %CloudEvents.Event{
      id: "42", specversion: "1.0", source: "foo", type: "bar", datacontenttype: "application/xml"}
    assert :ok == CloudEvents.Event.validate(event)
  end
end
