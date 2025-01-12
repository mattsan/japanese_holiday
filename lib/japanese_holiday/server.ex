defmodule JapaneseHoliday.Server do
  @moduledoc """
  A server of Japanese holidays.

  The server version of `JapaneseHoliday`.

  These are about the same codes.

  ```elixir
  {:ok, holidays} = JapaneseHoliday.load(force: true, save: false)
  JapaneseHoliday.lookup(holidays, 2023, 1, 1)
  #=> [{{2023, 1, 1}, "元日"}]
  ```

  ```elixir
  JapaneseHoliday.Server.start_link(force: true, save: false, name: :holidays)
  JapaneseHoliday.Server.lookup(:holidays, 2023, 1, 1)
  #=> [{{2023, 1, 1}, "元日"}]
  ```
  """

  use GenServer

  import JapaneseHoliday, only: [is_year: 1, is_month: 1, is_day: 1]

  @option_keys [:url, :save, :path, :force, :encoding]

  @doc """
  Starts a holiday server.

  ## Options

  - `options` - `JapaneseHoliday.load/1` options or `GenServer.start_link/3` options.
  """
  @spec start_link(Keyword.t()) :: {:ok, pid()}
  def start_link(options \\ []) when is_list(options) do
    {opts, gs_opts} = Keyword.split(options, @option_keys)
    GenServer.start_link(__MODULE__, opts, gs_opts)
  end

  @doc """
  Looks up holidays of the specific year.

  See `JapaneseHoliday.lookup/2`.
  """
  @spec lookup(pid(), JapaneseHoliday.year()) :: [JapaneseHoliday.holiday()]
  def lookup(pid, year) when is_year(year) do
    GenServer.call(pid, {:lookup, year, :_, :_})
  end

  @doc """
  Looks up holidays of the specific year and month.

  If no holidays in the month, returns a blank list.

  See `JapaneseHoliday.lookup/3`.
  """
  @spec lookup(pid(), JapaneseHoliday.year(), JapaneseHoliday.month()) ::
          [JapaneseHoliday.holiday()]
  def lookup(pid, year, month) when is_year(year) and is_month(month) do
    GenServer.call(pid, {:lookup, year, month, :_})
  end

  @doc """
  Looks up holidays of the specific date.

  If the day is not a holiday, returns a blank list.

  See `JapaneseHoliday.lookup/4`.
  """
  @spec lookup(pid(), JapaneseHoliday.year(), JapaneseHoliday.month(), JapaneseHoliday.day()) ::
          [JapaneseHoliday.holiday()]
  def lookup(pid, year, month, day) when is_year(year) and is_month(month) and is_day(day) do
    GenServer.call(pid, {:lookup, year, month, day})
  end

  @doc """
  Reloads holidays.

  ## Options

  - `options` - `JapaneseHoliday.load/1` options
  """
  # @spec reload(pid(), Keyword.t())
  def reload(pid, options \\ []) when is_list(options) do
    {opts, _} = Keyword.split(options, @option_keys)
    GenServer.cast(pid, {:reload, opts})
  end

  @impl true
  def init(options) do
    table = new_holidays_table()

    Process.send_after(self(), {:init_table, options}, 0)

    {:ok, %{table: table, options: options, loading: true, callers: []}}
  end

  @impl true
  def handle_info({:init_table, options}, state) do
    {:ok, holidays} = JapaneseHoliday.load(options)

    :ets.delete_all_objects(state.table)
    Enum.each(holidays, &insert_holiday(state.table, &1))

    reply_to_collers(state)

    {:noreply, %{state | loading: false, callers: []}}
  end

  @impl true
  def handle_call({:lookup, year, month, day}, from, state) do
    if state.loading do
      {:noreply, register_caller(state, from, {year, month, day})}
    else
      {:reply, lookup_holidays(state.table, year, month, day), state}
    end
  end

  @impl true
  def handle_cast({:reload, options}, state) do
    if state.loading do
      {:noreply, state}
    else
      Process.send_after(self(), {:init_table, Keyword.merge(state.options, options)}, 0)
      {:noreply, %{state | loading: true}}
    end
  end

  defp register_caller(state, caller, args) do
    update_in(state, [:callers], &[{caller, args} | &1])
  end

  defp reply_to_collers(state) do
    state.callers
    |> Enum.each(fn
      {caller, {year, month, day}} ->
        GenServer.reply(caller, lookup_holidays(state.table, year, month, day))
    end)
  end

  defp new_holidays_table do
    :ets.new(:holiday, [:ordered_set])
  end

  defp insert_holiday(table, holiday) do
    :ets.insert(table, holiday)
  end

  defp lookup_holidays(table, year, month, day) do
    :ets.select(table, [{{{year, month, day}, :_}, [], [:"$_"]}])
  end
end
