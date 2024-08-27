defmodule JapaneseHoliday.API do
  @url "https://www8.cao.go.jp/chosei/shukujitsu/syukujitsu.csv"

  defguardp is_success(status) when status in 200..299

  def download do
    [url: @url]
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
