defmodule JapaneseHoliday.WebAPI do
  @moduledoc """
  Downloads data from the network.
  """

  defguardp is_success(status) when status in 200..299

  @typedoc "HTTP response error."
  @type http_error() :: {:http_error, %{status: integer(), body: String.t()}}

  @typedoc "`Req` library error."
  @type req_error() :: {:req_error, Exception.t()}

  @type error() :: http_error() | req_error()

  @doc """
  Downloads data and converts its encoding to UTF-8.

  ## Options

  - `url` - URL of the data.
  - `encoding` - Encoding of the raw data.
  """
  @spec download(String.t(), String.t()) :: {:ok, String.t()} | {:error, error()}
  def download(url, encoding) when is_binary(url) do
    [url: url]
    |> Keyword.merge(Application.get_env(:japanese_holiday, :api_req_options, []))
    |> Req.request(decode_body: false)
    |> case do
      {:ok, %{status: status, body: body}} when is_success(status) ->
        {:ok, encode_from(body, encoding)}

      {:ok, %{status: status, body: body}} ->
        {:error, {:http_error, %{status: status, body: body}}}

      {:error, exception} ->
        {:error, {:req_error, exception}}
    end
  end

  @spec encode_from(String.t(), String.t()) :: String.t()
  defp encode_from(string, encoding) do
    case encoding do
      "utf-8" -> string
      _ -> :iconv.convert(encoding, "utf-8", string)
    end
  end
end
