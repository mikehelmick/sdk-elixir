# CloudEvents

An Elixir SDK for processing CloudEvents. Conforms to the CloudEvents 1.0 spec.

## Status

1. `CloudEvents.Event` module defines the structure of a CloudEvent. Provides
   encoding for JSON and binary data payloads.

2. `CloudEVents.HTTPClient` defines an HTTP Client that sends events via
   structured encoding.

## Still TODO

1. HTTP Server functionality to receive and respond to CloudEvents

2. Better handling of HTTP responses on the HTTP Client

3. Complete unit testing

4. Complete Documentation

5. Examples for using CloudEvents over HTTP with this SDK

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
