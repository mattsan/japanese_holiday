defmodule JapaneseHoliday.Storage do
  @moduledoc """
  Storage of CVS data.
  """

  alias JapaneseHoliday.API

  @doc """
  Load CSV data.

  - `path` - Path of downloaded file.
    If the file already exists, it doesn't download and return the content of the file.
    If not exists, downloads the CSV data, save to the path andd return the data.
  - `opts` - Options.
      - `:force` - If it's `true` force download (default: `false`).
      - `:save` - If it's `true` save the downloaded data to the path, if `false` not save (default: `true`).
  """
  @spec load(String.t(), Keyword.t()) :: {:ok, String.t()} | {:error, term()}
  def load(path, opts \\ []) when is_binary(path) and is_list(opts) do
    force? = Keyword.get(opts, :force, false)
    save? = Keyword.get(opts, :save, true)

    if !force? && File.exists?(path) do
      File.read(path)
    else
      API.download()
      |> save(path, save?)
    end
  end

  defp save({:error, _} = resp, _, _) do
    resp
  end

  defp save(resp, _, false) do
    resp
  end

  defp save({:ok, body}, path, true) do
    case mkdir(path) do
      :ok -> write(body, path)
      error -> error
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
end
