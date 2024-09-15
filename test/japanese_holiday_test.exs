defmodule JapaneseHolidayTest do
  use ExUnit.Case
  doctest JapaneseHoliday

  @moduletag response:
               :iconv.convert(
                 "utf-8",
                 "cp932",
                 File.read!(Path.expand("test/fixtures/holidays.csv"))
               )

  setup {JapaneseHolidayStab, :setup}
end
