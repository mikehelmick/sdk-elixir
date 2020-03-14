defmodule CloudEvents.HTTPServer do
  import CloudEvents.Event

  def serve(_function, options \\ []) do
    port = Keyword.get(options, :port, 8080)
    path = Keyword.get(options, :path, "/")
  end
end
