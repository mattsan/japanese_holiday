defmodule JapaneseHoliday.API do
  @moduledoc """
  Module of downloading CSV data from the network.
  """

  @default_url "https://www8.cao.go.jp/chosei/shukujitsu/syukujitsu.csv"

  defguardp is_success(status) when status in 200..299

  @doc """
  Downloads CSV data of public holidays in Japan from the site of Cabinet Office, Government of Japan.

  see "[National Holidays Policy](https://www8.cao.go.jp/chosei/shukujitsu/gaiyou.html)" (Japanese).
  """
  @spec download() :: {:ok, String.t()} | {:error, term()}
  def download do
    download(@default_url)
  end

  @doc """
  Downloads CSV data from `url`.
  """
  @spec download(String.t()) :: {:ok, String.t()} | {:error, term()}
  def download(url) when is_binary(url) do
    [url: url]
    |> Keyword.merge(Application.get_env(:japanese_holiday, :api_req_options, []))
    |> Req.request()
    |> case do
      {:ok, %{status: status, body: body}} when is_success(status) ->
        {:ok, encode_from_cp932(body)}

      {:ok, %{status: status, body: body}} ->
        {:error, {:http_error, %{status: status, body: body}}}

      error ->
        error
    end
  end

  defp encode_from_cp932(string) do
    :iconv.convert("cp932", "utf-8", string)
  end
end
