defmodule CloudEvents.HTTPServer do
  require Logger
  import CloudEvents.Event
  import Plug.Conn

  def serve_routes(handler_map, options \\ []) when is_map(handler_map) do
    port = Keyword.get(options, :port, 8080)

    errors =
      List.foldl(Map.to_list(handler_map), [], fn {path, _}, acc ->
        if String.starts_with?(path, "/") do
          acc
        else
          acc ++ ["Path `#{path}` will never match."]
        end
      end)

    if length(errors) == 0 do
      children = [
        {Plug.Cowboy,
         scheme: :http, plug: {CloudEvents.HTTPServer, [handler_map]}, options: [port: port]}
      ]

      opts = [strategy: :one_for_one, name: CloudEvents.HTTPServer.Supervisor]
      Supervisor.start_link(children, opts)
    else
      {:error, errors}
    end
  end

  @doc """
  Starts serving a single function on a single port/path (:8080/ by default).
  The callback function shoud be of the form

  `fn(%CloudEvents.Event{}) -> :ok | :error | {:error, reason} | {:reply, %CloudEvent.Event{}}`
  """
  @spec serve(CloudEvents.Handler, List.t()) :: {:ok, pid()} | {:error, any}
  def serve(handler, options \\ []) do
    port = Keyword.get(options, :port, 8080)
    path = Keyword.get(options, :path, "/")

    routes = %{path => handler}

    serve_routes(routes, port: port)
  end

  def init(options) do
    options
  end

  def call(conn, [routes]) do
    # first, see if there is a route that matches
    case routes[conn.request_path] do
      nil ->
        conn |> put_resp_content_type("text/plain") |> send_resp(404, "not found.")

      handler ->
        {:ok, body, conn} = read_body(conn, length: 11_000_000)

        headers = Map.new(conn.req_headers)
        IO.puts("HEADERS: #{inspect(headers)}")

        case(CloudEvents.HTTPDecoder.decode(headers, body)) do
          {:ok, event} ->
            case validate(event) do
              :ok ->
                handler.handle_event(event, conn: conn)
                conn |> put_resp_content_type("text/plain") |> send_resp(202, "")

              {:error, errors} ->
                Logger.error("Invalid CloudEvent received: #{inspect(errors)}")

                conn
                |> put_resp_content_type("text/plain")
                |> send_resp(400, "invalid request.")
            end

          {:error, reason} ->
            Logger.error("Error parsing event: #{inspect(reason)}")

            conn
            |> put_resp_content_type("text/plain")
            |> send_resp(500, "internal server error.")
        end
    end
  end
end
