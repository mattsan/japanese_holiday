defmodule JapaneseHoliday.Storage do
  @moduledoc """
  Storage of CVS data.
  """

  alias JapaneseHoliday.WebAPI
  require Logger

  @doc """
  Loads CSV data.

  See `JapaneseHoliday.load/1`.
  """
  @spec load(Keyword.t()) :: {:ok, String.t()} | {:error, JapaneseHoliday.error()}
  def load(opts) when is_list(opts) do
    case parse_options(opts) do
      {:ok, options} ->
        if !options.force? && is_binary(options.path) && File.exists?(options.path) do
          register_log(:loading, options.path)
          File.read(options.path)
        else
          register_log(:downloading, options.url)

          WebAPI.download(options.url, options.encoding)
          |> save(options.path, options.save?)
        end

      error ->
        error
    end
  end

  @spec parse_options(Keyword.t()) :: {:ok, map()} | {:error, JapaneseHoliday.option_error()}
  defp parse_options(opts) do
    url = opts[:url]
    path = opts[:path]
    save? = Keyword.get(opts, :save, false)
    force? = Keyword.get(opts, :force, false)
    encoding = Keyword.get(opts, :encoding, "utf-8")

    cond do
      !is_binary(url) ->
        {:error, {:url_must_be_string, url}}

      save? && !is_binary(path) ->
        {:error, {:path_must_be_string_if_to_save, [save: save?, path: path]}}

      true ->
        {:ok, %{url: url, path: path, save?: save?, force?: force?, encoding: encoding}}
    end
  end

  @spec save({:ok, String.t()} | {:error, term()}, String.t(), boolean()) ::
          {:ok, String.t()} | {:error, term()}
  defp save(resp, path, save?)

  defp save({:error, _} = resp, _, _) do
    resp
  end

  defp save(resp, _, false) do
    resp
  end

  defp save({:ok, body}, path, true) do
    case mkdir(path) do
      :ok ->
        register_log(:saving, path)
        write(body, path)

      error ->
        error
    end
  end

  defp mkdir(path) do
    dir = Path.dirname(path)

    if File.exists?(dir) do
      :ok
    else
      File.mkdir_p(dir)
    end
  end

  defp write(body, path) do
    case File.write(path, body) do
      :ok -> {:ok, body}
      error -> error
    end
  end

  defp register_log(:loading, path),
    do: Logger.debug("JapaneseHoliday: loading CSV file from #{path}")

  defp register_log(:saving, path),
    do: Logger.debug("JapaneseHoliday: saving CSV file to #{path}")

  defp register_log(:downloading, url),
    do: Logger.debug("JapaneseHoliday: downloading CSV data from #{url}")
end
