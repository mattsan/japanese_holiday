defmodule JapaneseHoliday.Server do
  use GenServer

  @gen_server_options [:name, :timeout, :debug, :spawn_opt, :hibernate_after]

  @spec start_link(Keyword.t()) :: {:ok, pid()}
  def start_link(opts \\ []) when is_list(opts) do
    {options, init_arg} = Keyword.split(opts, @gen_server_options)

    GenServer.start_link(__MODULE__, init_arg, options)
  end

  @spec lookup(pid(), :calendar.year()) :: [JapaneseHoliday.holiday()]
  def lookup(pid, year) do
    GenServer.call(pid, {:lookup, year, :_, :_})
  end

  @spec lookup(pid(), :calendar.year(), :calendar.month()) :: [JapaneseHoliday.holiday()]
  def lookup(pid, year, month) do
    GenServer.call(pid, {:lookup, year, month, :_})
  end

  @spec lookup(pid(), :calendar.year(), :calendar.month(), :calendar.day()) :: [
          JapaneseHoliday.holiday()
        ]
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
