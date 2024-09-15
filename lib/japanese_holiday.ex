defmodule JapaneseHoliday do
  @moduledoc """
  Public holidays in Japan.

  Dowloads or loads CSV file, parses and looks up.

  ## Example

  ```elixir
  # downloads
  {:ok, holidays} = JapaneseHoliday.load(force: true, save: false) # always download and not save

  # looks up
  JapaneseHoliday.lookup(holidays, 2024, 1, 1)
  #=> [{{2024, 1, 1}, "元日}]
  JapaneseHoliday.lookup(holidays, 2024, 1)
  #=> [{{2024, 1, 1}, "元日"}, {{2024, 1, 8}, "成人の日"}]
  JapaneseHoliday.lookup(holidays, 2024, 6)
  #=> []
  ```
  """

  alias JapaneseHoliday.{Parser, Storage, WebAPI}

  NimbleCSV.define(JapaneseHoliday.Parser, moduledoc: false)

  @url "https://www8.cao.go.jp/chosei/shukujitsu/syukujitsu.csv"
  @default_options [url: @url, encoding: "cp932"]

  @type year :: 1955..9999
  @type month :: 1..12
  @type day :: 1..31
  @type date :: {year(), month(), day()}
  @type holiday :: {date(), String.t()}
  @type option_error() ::
          {:url_must_be_string, term()} | {:path_must_be_string_if_to_save, term()}
  @type file_error() :: File.posix()
  @type error() :: option_error() | file_error() | WebAPI.error()

  defguardp is_year(year) when year in 1955..9999
  defguardp is_month(month) when month in 1..12
  defguardp is_day(day) when day in 1..31

  @doc """
  Loads public holidays in Japan.

  ## Options

  - `:url` - URL of CSV of holidays. (default: [`#{@url}`](#{@url}))
  - `:save` - If `true` save the downloaded CSV data. (default: `false`)
  - `:path` - Path to save or load the downloaded CSV data. If `:save` is `true`, this options is required.
  - `:force` - If `true` force download the CSV data. (default: `false`)
  - `:encoding` - Encoding of the CSV data to download. (default: `"cp932"`)
  """
  @spec load(Keyword.t()) :: {:ok, [holiday()]} | {:error, error()}
  def load(opts \\ []) when is_list(opts) do
    case @default_options |> Keyword.merge(opts) |> Storage.load() do
      {:ok, csv} ->
        {:ok, parse(csv)}

      error ->
        error
    end
  end

  @doc """
  Returns a list of holidays of the year.

  If no holidays in the year, returns an empty list.

  ## Example

  ```elixir
  iex> {:ok, holidays} = JapaneseHoliday.load(force: true, save: false)
  iex> JapaneseHoliday.lookup(holidays, 2023)
  [
    {{2023, 1, 1}, "元日"},
    {{2023, 1, 2}, "休日"},
    {{2023, 1, 9}, "成人の日"},
    {{2023, 2, 11}, "建国記念の日"},
    {{2023, 2, 23}, "天皇誕生日"},
    {{2023, 3, 21}, "春分の日"},
    {{2023, 4, 29}, "昭和の日"},
    {{2023, 5, 3}, "憲法記念日"},
    {{2023, 5, 4}, "みどりの日"},
    {{2023, 5, 5}, "こどもの日"},
    {{2023, 7, 17}, "海の日"},
    {{2023, 8, 11}, "山の日"},
    {{2023, 9, 18}, "敬老の日"},
    {{2023, 9, 23}, "秋分の日"},
    {{2023, 10, 9}, "スポーツの日"},
    {{2023, 11, 3}, "文化の日"},
    {{2023, 11, 23}, "勤労感謝の日"}
  ]
  ```
  """
  @spec lookup([holiday()], year()) :: [holiday()]
  def lookup(holidays, year) when is_list(holidays) and is_year(year) do
    for {{^year, _, _}, _} = holiday <- holidays do
      holiday
    end
  end

  @doc """
  Returns a list of holidays of the month.

  If no holidays in the month, returns an empty list.

  ## Example

  ```elixir
  iex> {:ok, holidays} = JapaneseHoliday.load(force: true, save: false)
  iex> JapaneseHoliday.lookup(holidays, 2023, 1)
  [
    {{2023, 1, 1}, "元日"},
    {{2023, 1, 2}, "休日"},
    {{2023, 1, 9}, "成人の日"}
  ]
  iex> JapaneseHoliday.lookup(holidays, 2023, 6)
  []
  ```
  """
  @spec lookup([holiday()], year(), month()) :: [holiday()]
  def lookup(holidays, year, month)
      when is_list(holidays) and is_year(year) and is_month(month) do
    for {{^year, ^month, _}, _} = holiday <- holidays do
      holiday
    end
  end

  @doc """
  Returns a list of holiday of the date.

  If the day is not a holiday, returns an empty list.
  ## Example

  ```elixir
  iex> {:ok, holidays} = JapaneseHoliday.load(force: true, save: false)
  iex> JapaneseHoliday.lookup(holidays, 2023, 1, 1)
  [{{2023, 1, 1}, "元日"}]
  iex> JapaneseHoliday.lookup(holidays, 2023, 1, 3)
  []
  ```
  """
  @spec lookup([holiday()], year(), month(), day()) :: [holiday()]
  def lookup(holidays, year, month, day)
      when is_list(holidays) and is_year(year) and is_month(month) and is_day(day) do
    for {{^year, ^month, ^day}, _} = holiday <- holidays do
      holiday
    end
  end

  @doc """
  Parses CSV data to holidays data.

  ## Examples

  ```elixir
  iex> JapaneseHoliday.parse("date,name\\r\\n2024/1/1,元日\\r\\n")
  [{{2024, 1, 1}, "元日"}]
  iex> JapaneseHoliday.parse("date,name\\r\\n")
  []
  ```
  """
  @spec parse(String.t()) :: [holiday()]
  def parse(csv) when is_binary(csv) do
    csv
    |> Parser.parse_string()
    |> Enum.map(&parse_row/1)
    |> Enum.reject(&is_nil/1)
  end

  @spec parse_row([String.t()]) :: {:calendar.date(), String.t()} | nil
  defp parse_row([date, name]) do
    case capture_date(date) do
      {_, _, _} = ymd -> {ymd, name}
      _ -> nil
    end
  end

  defp parse_row(_) do
    nil
  end

  @spec capture_date(String.t()) :: :calendar.date() | nil
  defp capture_date(date) do
    import String, only: [to_integer: 1]

    case Regex.named_captures(~r/(?<year>\d{4})\/(?<month>\d{1,2})\/(?<day>\d{1,2})/, date) do
      %{"year" => year, "month" => month, "day" => day} ->
        {to_integer(year), to_integer(month), to_integer(day)}

      _ ->
        nil
    end
  end
end
