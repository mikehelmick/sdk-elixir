defmodule CloudEvents.Encoding do
  def identity_encoding(x), do: x

  def json_encoding(x) do
    {:ok, json} = Poison.encode(x)
    json
  end

  def json_decode(json) do
    Poison.decode(json)
  end

  def base64_encoding(x) do
    Base.encode64(x)
  end
end
