defmodule JapaneseHoliday.WebAPITest do
  use ExUnit.Case

  alias JapaneseHoliday.WebAPI

  @dummy_url "https://example.com/syukujitsu.csv"

  doctest WebAPI

  setup {JapaneseHolidayStab, :setup}

  describe "success" do
    @tag response: :iconv.convert("utf-8", "cp932", "国民の祝日・休日月日,国民の祝日・休日名称\r\n2024/1/1,元日\r\n")
    test "greets the world" do
      assert {:ok, "国民の祝日・休日月日,国民の祝日・休日名称\r\n2024/1/1,元日\r\n"} ==
               WebAPI.download(@dummy_url, "cp932")
    end
  end

  describe "failure" do
    @tag status: 400, response: "bad request"
    test "greets the world" do
      assert {:error, {:http_error, %{status: 400, body: "bad request"}}} ==
               WebAPI.download(@dummy_url, "cp932")
    end
  end
end
