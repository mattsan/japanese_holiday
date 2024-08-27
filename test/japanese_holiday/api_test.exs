defmodule JapaneseHoliday.APITest do
  use ExUnit.Case

  alias JapaneseHoliday.API

  doctest API

  setup(context) do
    status = Map.get(context, :status, 200)
    response = Map.fetch!(context, :response)

    Req.Test.stub(API, fn conn ->
      conn
      |> Plug.Conn.put_status(status)
      |> Req.Test.text(response)
    end)
  end

  describe "success" do
    @tag response: :iconv.convert("utf-8", "cp932", "国民の祝日・休日月日,国民の祝日・休日名称\r\n2024/1/1,元日\r\n")
    test "greets the world" do
      assert {:ok, "国民の祝日・休日月日,国民の祝日・休日名称\r\n2024/1/1,元日\r\n"} == API.download()
    end
  end

  describe "failure" do
    @tag response: "bad request", status: 400
    test "greets the world" do
      assert {:error, {:http_error, %{status: 400, body: "bad request"}}} == API.download()
    end
  end
end
