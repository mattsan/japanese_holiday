defmodule JapaneseHoliday.WebAPITest do
  use ExUnit.Case

  alias JapaneseHoliday.WebAPI

  @url "https://www8.cao.go.jp/chosei/shukujitsu/syukujitsu.csv"

  doctest WebAPI

  setup(context) do
    status = Map.get(context, :status, 200)
    response = Map.fetch!(context, :response)

    Req.Test.stub(WebAPI, fn conn ->
      conn
      |> Plug.Conn.put_status(status)
      |> Req.Test.text(response)
    end)
  end

  describe "success" do
    @tag response: :iconv.convert("utf-8", "cp932", "国民の祝日・休日月日,国民の祝日・休日名称\r\n2024/1/1,元日\r\n")
    test "greets the world" do
      assert {:ok, "国民の祝日・休日月日,国民の祝日・休日名称\r\n2024/1/1,元日\r\n"} == WebAPI.download(@url, "cp932")
    end
  end

  describe "failure" do
    @tag response: "bad request", status: 400
    test "greets the world" do
      assert {:error, {:http_error, %{status: 400, body: "bad request"}}} ==
               WebAPI.download(@url, "cp932")
    end
  end
end
