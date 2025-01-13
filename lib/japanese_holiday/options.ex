defmodule JapaneseHoliday.Options do
  @moduledoc """
  Options struct
  """

  defstruct [:url, :save?, :path, :force?, :encoding]

  @type t() :: %__MODULE__{
          url: String.t(),
          save?: boolean(),
          path: String.t() | nil,
          force?: boolean(),
          encoding: String.t()
        }
  @type error() ::
          {:url_must_be_string, [url: term()]}
          | {:path_must_be_string_if_to_save, [save: term(), path: term()]}
          | {:unknown_options, [term()]}

  @default %{
    url: "https://www8.cao.go.jp/chosei/shukujitsu/syukujitsu.csv",
    path: nil,
    save?: false,
    force?: false,
    encoding: "cp932"
  }

  @doc """
  Parses a keyword list and returns an Options struct.

  ## Option keys

  | key         | default |
  |-------------|---|
  | `:url`      | `#{inspect(@default.url)}` |
  | `:path`     | `#{inspect(@default.path)}` |
  | `:save`     | `#{inspect(@default.save?)}` |
  | `:force`    | `#{inspect(@default.force?)}` |
  | `:encoding` | `#{inspect(@default.encoding)}` |

  ## Example

  ```elixir
  iex> JapaneseHoliday.Options.parse([])
  {
    :ok,
    %JapaneseHoliday.Options{
      url: "https://www8.cao.go.jp/chosei/shukujitsu/syukujitsu.csv",
      save?: false,
      path: nil,
      force?: false,
      encoding: "cp932"
    }
  }
  ```

  ```elixir
  iex> JapaneseHoliday.Options.parse(url: "https://example.com/holidays.csv", force: true)
  {
    :ok,
    %JapaneseHoliday.Options{
      url: "https://example.com/holidays.csv",
      save?: false,
      path: nil,
      force?: true,
      encoding: "cp932"
    }
  }
  ```

  ```elixir
  iex> JapaneseHoliday.Options.parse(save: true)
  {:error, {:path_must_be_string_if_to_save, [save: true, path: nil]}}
  ```

  """
  @spec parse(Keyword.t()) :: {:ok, t()} | {:error, error()}
  def parse(opts) do
    case Keyword.split(opts, [:url, :path, :save, :force, :encoding]) do
      {options, []} ->
        url = Keyword.get(options, :url, @default.url)
        path = Keyword.get(options, :path, @default.path)
        save? = Keyword.get(options, :save, @default.save?)
        force? = Keyword.get(options, :force, @default.force?)
        encoding = Keyword.get(options, :encoding, @default.encoding)

        cond do
          !is_binary(url) ->
            {:error, {:url_must_be_string, [url: url]}}

          save? && !is_binary(path) ->
            {:error, {:path_must_be_string_if_to_save, [save: save?, path: path]}}

          true ->
            {:ok,
             %__MODULE__{url: url, path: path, save?: save?, force?: force?, encoding: encoding}}
        end

      {_, unknowns} ->
        {:error, {:unknown_options, Keyword.keys(unknowns)}}
    end
  end

  @doc false
  @spec default() :: map()
  def default do
    @default
  end
end
