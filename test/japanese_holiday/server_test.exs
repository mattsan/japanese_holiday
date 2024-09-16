defmodule JapaneseHoliday.ServerTest do
  use ExUnit.Case
  alias JapaneseHoliday.Server
  doctest Server

  @fixture_file "test/fixtures/holidays.csv"

  setup do
    {:ok, pid} = start_supervised({Server, [path: @fixture_file]})

    [pid: pid]
  end

  describe "lookup/2" do
    test "指定した年のすべての祝日を返すこと", %{pid: pid} do
      expected = [
        {{2023, 1, 1}, "元日"},
        {{2023, 1, 2}, "休日"},
        {{2023, 1, 9}, "成人の日"},
        {{2023, 2, 11}, "建国記念の日"},
        {{2023, 2, 23}, "天皇誕生日"},
        {{2023, 3, 21}, "春分の日"},
        {{2023, 4, 29}, "昭和の日"},
        {{2023, 5, 3}, "憲法記念日"},
        {{2023, 5, 4}, "みどりの日"},
        {{2023, 5, 5}, "こどもの日"},
        {{2023, 7, 17}, "海の日"},
        {{2023, 8, 11}, "山の日"},
        {{2023, 9, 18}, "敬老の日"},
        {{2023, 9, 23}, "秋分の日"},
        {{2023, 10, 9}, "スポーツの日"},
        {{2023, 11, 3}, "文化の日"},
        {{2023, 11, 23}, "勤労感謝の日"}
      ]

      assert expected == JapaneseHoliday.Server.lookup(pid, 2023)
    end
  end

  describe "lookup/3" do
    test "指定した月のすべての祝日を返すこと", %{pid: pid} do
      expected = [
        {{2023, 1, 1}, "元日"},
        {{2023, 1, 2}, "休日"},
        {{2023, 1, 9}, "成人の日"}
      ]

      assert expected == JapaneseHoliday.Server.lookup(pid, 2023, 1)
    end

    test "指定した月に祝日がない場合、空のリストを返すこと", %{pid: pid} do
      assert [] == JapaneseHoliday.Server.lookup(pid, 2023, 6)
    end
  end

  describe "lookup/4" do
    test "指定した日の祝日を返すこと", %{pid: pid} do
      expected = [{{2023, 1, 1}, "元日"}]

      assert expected == JapaneseHoliday.Server.lookup(pid, 2023, 1, 1)
    end

    test "指定した日が祝日でない場合、空のリストを返すこと", %{pid: pid} do
      assert [] == JapaneseHoliday.Server.lookup(pid, 2023, 1, 3)
    end
  end
end
