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
        {:ok, body, conn} = read_body(conn, length: 100_000)

        headers = Map.new(conn.req_headers)

        case(CloudEvents.HTTPDecoder.decode(headers, body)) do
          {:ok, event} ->
            case validate(event) do
              :ok ->
                case handler.handle_event(event, conn: conn) do
                  :ok ->
                    conn |> put_resp_content_type("text/plain") |> send_resp(202, "")

                  {:reply, reply_event} when is_struct(reply_event) ->
                    # TODO: Elixir 1.11 will allow for validation of a specific struct
                    case valid?(reply_event) do
                      true ->
                        {headers, body} = CloudEvents.HTTPEncoder.binary(reply_event)

                        conn = List.foldl(Map.to_list(headers), conn,
                           fn {k, v}, conn -> put_resp_header(conn, k, v) end)
                        send_resp(conn, 200, body)

                      false ->
                        {:error, errors} = validate(reply_event)
                        Logger.error("Tried to reply with invalid event: \nCloudEvent #{inspect(reply_event)}\nError: #{inspect(errors)}")
                        conn
                        |> put_resp_content_type("text/plain")
                        |> send_resp(500, "internal server error.")
                    end

                  {:error, reason} ->
                    Logger.error("Invoke filed with error: #{inspect(reason)}")
                    conn
                    |> put_resp_content_type("text/plain")
                    |> send_resp(500, "#{inspect(reason)}")
                end

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
