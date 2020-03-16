# CloudEvents

An Elixir SDK for processing CloudEvents. Conforms to the CloudEvents 1.0 spec.

## Status

TL;DR - Event module for manipulating events, working HTTP client for both
binary and structured CloudEvents, working server for both structured and
binary encoding.

1. `CloudEvents.Event` module defines the structure of a CloudEvent. Provides
   encoding for JSON and binary data payloads.

2. `CloudEvents.HTTPClient` defines an HTTP Client that sends events via
   structured encoding. As an example, using `iex -S mix`

```elixir
iex(1)> import CloudEvents.Event
CloudEvents.Event
iex(2)> data = %{"firstname" => "steve", "lastname" => "service"}    
%{"firstname" => "steve", "lastname" => "service"}
iex(3)> event = CloudEvents.Event.new() |> with_id("42") |> with_type("com.example.person") |> with_source("hr") |> with_time_now() |> with_data(data) |> with_data_json_encoding()
%CloudEvents.Event{
  data: %{"firstname" => "steve", "lastname" => "service"},
  datacontenttype: "application/json",
  dataschema: nil,
  encoding_fn: &CloudEvents.Encoding.json_encoding/1,
  extensions: %{},
  id: "42",
  source: "hr",
  specversion: "1.0",
  subject: nil,
  time: "2020-03-15T22:58:12.320398Z",
  type: "com.example.person"
}
iex(4)> CloudEvents.HTTPClient.send("http://localhost:8080/", event)
{:ok,
 %HTTPoison.Response{
   body: "",
   headers: [{"Content-Length", "0"}, {"Date", "Sun, 15 Mar 2020 22:58:42 GMT"}],
   request: %HTTPoison.Request{
     body: "{\"lastname\":\"service\",\"firstname\":\"steve\"}",
     headers: [
       {"Content-Type", "application/json"},
       {"ce-id", "42"},
       {"ce-source", "hr"},
       {"ce-specversion", "1.0"},
       {"ce-time", "2020-03-15T22:58:12.320398Z"},
       {"ce-type", "com.example.person"}
     ],
     method: :put,
     options: [],
     params: %{},
     url: "http://localhost:8080/"
   },
   request_url: "http://localhost:8080/",
   status_code: 202
 }}
iex(5)>
```

3. `CloudEvents.HTTPServer` defines a server for receiving HTTP CloudEvents.
   Example of running a service in `iex -S mix` and receiving a CloudEvent
   with the stdout logging handler (`PrintHandler`).

```elixir
iex(1)> CloudEvents.HTTPServer.serve(CloudEvents.Example.PrintHandler)
{:ok, #PID<0.302.0>}
Received CloudEvent:
%CloudEvents.Event{
  data: %{"age" => 42, "firstname" => "Steve", "lastname" => "Service"}, datacontenttype: "application/json",
  dataschema: "http://scehams.in-the-cloud.dev/awesome",
  encoding_fn: &CloudEvents.Encoding.json_encoding/1,
  extensions: %{},
  id: "42",
  source: "/awesome/file/path",
  specversion: "1.0",
  subject: "math",
  time: "2020-03-15T23:02:51.706597Z",
  type: "com.example.awesome"}
----------

iex(2)>
```

## Still TODO

1. Implement handling of responses for both client and server.

2. Complete unit testing

3. Complete Documentation

4. Examples for using CloudEvents over HTTP with this SDK

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `cloudevents` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:cloudevents, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/cloudevents](https://hexdocs.pm/cloudevents).
