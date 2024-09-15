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
  JapaneseHoliday.Server.start_link([force: true, save: false], [name: :holidays])
  JapaneseHoliday.Server.lookup(:holidays, 2023, 1, 1)
  #=> [{{2023, 1, 1}, "元日"}]
  ```
  """

  use GenServer

  @doc """
  Starts a holiday server.

  ## Options

  - `opts` - `JapaneseHoliday.load/1` options
  - `gs_opts` - GenServer's starting options. See `GenServer.start_link/3`
  """
  @spec start_link(Keyword.t(), Keyword.t()) :: {:ok, pid()}
  def start_link(opts \\ [], gs_opts \\ []) when is_list(opts) do
    GenServer.start_link(__MODULE__, opts, gs_opts)
  end

  @doc """
  Looks up holidays of the specific year.

  See `JapaneseHoliday.lookup/2`.
  """
  @spec lookup(pid(), JapaneseHoliday.year()) :: [JapaneseHoliday.holiday()]
  def lookup(pid, year) do
    GenServer.call(pid, {:lookup, year, :_, :_})
  end

  @doc """
  Looks up holidays of the specific year and month.

  If no holidays in the month, returns a blank list.

  See `JapaneseHoliday.lookup/3`.
  """
  @spec lookup(pid(), JapaneseHoliday.year(), JapaneseHoliday.month()) ::
          [JapaneseHoliday.holiday()]
  def lookup(pid, year, month) do
    GenServer.call(pid, {:lookup, year, month, :_})
  end

  @doc """
  Looks up holidays of the specific date.

  If the day is not a holiday, returns a blank list.

  See `JapaneseHoliday.lookup/4`.
  """
  @spec lookup(pid(), JapaneseHoliday.year(), JapaneseHoliday.month(), JapaneseHoliday.day()) ::
          [JapaneseHoliday.holiday()]
  def lookup(pid, year, month, day) do
    GenServer.call(pid, {:lookup, year, month, day})
  end

  @impl true
  def init(options) do
    table = :ets.new(:holiday, [:ordered_set])

    Process.send_after(self(), :init_table, 0)

    {:ok, %{table: table, options: options}}
  end

  @impl true
  def handle_info(:init_table, state) do
    {:ok, holidays} = JapaneseHoliday.load(state.options)

    Enum.each(holidays, &:ets.insert(state.table, &1))

    {:noreply, state}
  end

  @impl true
  def handle_call({:lookup, year, month, day}, _from, state) do
    holidays = :ets.select(state.table, [{{{year, month, day}, :_}, [], [:"$_"]}])

    {:reply, holidays, state}
  end
end
