defmodule CloudEvents.Encoding do
  def identity_encoding(x), do: x

  def json_encoding(x) do
    {:ok, json} = Poison.encode(x)
    json
  end

  def json_decode(json) do
    {:ok, data} = Poison.decode(json)
    data
  end

  def base64_encoding(x) do
    Base.encode64(x)
  end

  def base64_decoding(x) do
    {:ok, data} = Base.decode64(x)
    data
  end
end
