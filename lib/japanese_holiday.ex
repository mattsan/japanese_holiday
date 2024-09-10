defmodule JapaneseHoliday do
  alias JapaneseHoliday.{Parser, Storage}

  NimbleCSV.define(JapaneseHoliday.Parser, moduledoc: false)

  @type holiday :: {:calendar.date(), String.t()}

  @url "https://www8.cao.go.jp/chosei/shukujitsu/syukujitsu.csv"
  @default_options [url: @url, encoding: "cp932"]

  @doc """
  Loads public holidays in Japan.

  ## options

  - `:url` - URL of CSV of holidays. (default: `#{@url}`)
  - `:save` - If `true` save downloaded CSV data. (default: `false`)
  - `:path` - Path to save or load downloaded CSV data. If `save` is `true`, this options is required.
  - `:force` - If `true` force download. (default: `false`)
  - `:encoding` - Encoding of the CSV data to download. (default: `"cp932"`)
  """
  @spec load(Keyword.t()) :: {:ok, [holiday()]} | {:error, term()}
  def load(opts \\ []) when is_list(opts) do
    case @default_options |> Keyword.merge(opts) |> Storage.load() do
      {:ok, csv} ->
        {:ok, parse(csv)}

      error ->
        error
    end
  end

  @doc """
  Parses CSV data to holidays data.

  ## Examples

  ```elixir
  iex> JapaneseHoliday.parse("date,name\\r\\n2024/1/1,元日\\r\\n")
  [{{2024, 1, 1}, "元日"}]
  ```
  """
  @spec parse(String.t()) :: [holiday()]
  def parse(csv) when is_binary(csv) do
    csv
    |> Parser.parse_string()
    |> Enum.map(&parse_row/1)
    |> Enum.reject(&is_nil/1)
  end

  defp parse_row([date, name]) do
    import String, only: [to_integer: 1]

    Regex.named_captures(~r/(?<year>\d{4})\/(?<month>\d{1,2})\/(?<day>\d{1,2})/, date)
    |> case do
      %{"year" => year, "month" => month, "day" => day} ->
        {{to_integer(year), to_integer(month), to_integer(day)}, name}

      _ ->
        nil
    end
  end

  defp parse_row(_) do
    nil
  end
end
