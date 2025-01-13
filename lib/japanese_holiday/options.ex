defmodule JapaneseHoliday.Options do
  @moduledoc """
  Options struct
  """

  defstruct [:url, :path, :save?, :force?, :encoding]

  @type t() :: %__MODULE__{
          url: String.t(),
          path: String.t() | nil,
          save?: boolean(),
          force?: boolean(),
          encoding: String.t()
        }
  @type error() ::
          {:url_must_be_string, [url: term()]}
          | {:path_must_be_string_if_to_save, [save: term(), path: term()]}
          | {:unknown_options, [term()]}

  @default [
    url: "https://www8.cao.go.jp/chosei/shukujitsu/syukujitsu.csv",
    path: nil,
    save: false,
    force: false,
    encoding: "cp932"
  ]

  @doc """
  Parses a keyword list and returns an Options struct.

  ## Option keys

  | key         | default                           |
  |-------------|-----------------------------------|
  | `:url`      | `#{inspect(@default[:url])}`      |
  | `:path`     | `#{inspect(@default[:path])}`     |
  | `:save`     | `#{inspect(@default[:save])}`     |
  | `:force`    | `#{inspect(@default[:force])}`    |
  | `:encoding` | `#{inspect(@default[:encoding])}` |

  ## Examples

  ```elixir
  iex> JapaneseHoliday.Options.parse([])
  {
    :ok,
    %JapaneseHoliday.Options{
      url: "https://www8.cao.go.jp/chosei/shukujitsu/syukujitsu.csv",
      path: nil,
      save?: false,
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
      path: nil,
      save?: false,
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
        options = Keyword.merge(@default, options)

        cond do
          !is_binary(options[:url]) ->
            {:error, {:url_must_be_string, [url: options[:url]]}}

          options[:save] && !is_binary(options[:path]) ->
            {
              :error,
              {:path_must_be_string_if_to_save, [save: options[:save], path: options[:path]]}
            }

          true ->
            {
              :ok,
              %__MODULE__{
                url: options[:url],
                path: options[:path],
                save?: options[:save],
                force?: options[:force],
                encoding: options[:encoding]
              }
            }
        end

      {_, unknowns} ->
        {:error, {:unknown_options, Keyword.keys(unknowns)}}
    end
  end

  @doc false
  @spec default(atom) :: map()
  def default(key) when is_atom(key), do: @default[key]

  @doc false
  @spec keys() :: [atom()]
  def keys, do: [:url, :path, :save, :force, :encoding]
end
