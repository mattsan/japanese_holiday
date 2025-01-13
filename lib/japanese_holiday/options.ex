defmodule JapaneseHoliday.Options do
  @moduledoc """
  Options
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

  @default %{
    url: "https://www8.cao.go.jp/chosei/shukujitsu/syukujitsu.csv",
    path: nil,
    save?: false,
    force?: false,
    encoding: "cp932"
  }

  @spec parse(Keyword.t()) :: {:ok, t()} | {:error, error()}
  def parse(opts) do
    url = Keyword.get(opts, :url, @default.url)
    path = Keyword.get(opts, :path, @default.path)
    save? = Keyword.get(opts, :save, @default.save?)
    force? = Keyword.get(opts, :force, @default.force?)
    encoding = Keyword.get(opts, :encoding, @default.encoding)

    cond do
      !is_binary(url) ->
        {:error, {:url_must_be_string, [url: url]}}

      save? && !is_binary(path) ->
        {:error, {:path_must_be_string_if_to_save, [save: save?, path: path]}}

      true ->
        {:ok, %__MODULE__{url: url, path: path, save?: save?, force?: force?, encoding: encoding}}
    end
  end

  @doc false
  @spec default() :: map()
  def default do
    @default
  end
end
