# JapaneseHoliday

Public holidays in Japan.

Dowloads or loads CSV file, parses and looks up.


- [「国民の祝日」について - 内閣府](https://www8.cao.go.jp/chosei/shukujitsu/gaiyou.html) (About "National Holidays" - Cabinet Office) (Japanese)
- [CSV data](https://www8.cao.go.jp/chosei/shukujitsu/syukujitsu.csv) (from 1955 to the next year)

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `japanese_holiday` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:japanese_holiday, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/japanese_holiday>.

## Examples

### Loads holidays data

```elixir
# download CSV data and save it to the path.
{:ok, holidays} = JapaneseHoliday.load(path: "priv/csv/holidays.csv", save: true)

# When CSV file already exists, load the file without downloading.
{:ok, holidays} = JapaneseHoliday.load(path: "priv/csv/holidays.csv", save: true)
```

### Looks up

```elixir
JapaneseHoliday.lookup(holidays, 2024, 1, 1)
#=> [{{2024, 1, 1}, "元日"}]
```

```elixir
JapaneseHoliday.lookup(holidays, 2024, 1, 2)
#=> []
```

```elixir
JapaneseHoliday.lookup(holidays, 2024, 1)
#=> [{{2024, 1, 1}, "元日"}, {{2024, 1, 8}, "成人の日"}]
```

```elixir
JapaneseHoliday.lookup(holidays, 2024, 6)
#=> []
```

### Server

```elixir
{:ok, pid} = JapaneseHoliday.Server.start_link(path: "priv/csv/holidays.csv", save: true)
```

```elixir
JapaneseHoliday.Server.lookup(pid, 2024, 1, 1)
#=> [{{2024, 1, 1}, "元日"}]
```

## Tests your applications with this package

If your application uses this package, please control the behavior of the package using config files, for example.

Prepare a config file like the following:

```elixir
# config/config.exs
config :my_app, JapaneseHoliday,
  path: "priv/csv/holidays.csv"

import_config "#{config_env()}.exs" # Prepare config files for each environment.
```

Prepare a config file for testing.
This example is configured to load the fixture file `test/fixtures/holidays.csv`.

```elixir
# config/test.exs
config :my_app, JapaneseHoliday,
  path: "test/fixtures/holidays.csv",
```

Read the contents specified in the config file and set them as options.

```elixir
options = Application.fetch_env!(:my_app, JapaneseHoliday)

{:ok, holidays} = JapaneseHoliday.load(options)
```

If you want to start `JapaneseHoliday.Server` with Supervisor, set it as follows.

```elixir
options = Application.fetch_env!(:my_app, JapaneseHoliday)

children = [
  {JapaneseHoliday.Server, Keyword.merge(options, name: JapaneseCalendar.Holiday)}
]

opts = [strategy: :one_for_one, name: MyApp.Supervisor]
Supervisor.start_link(children, opts)
```
