defmodule JapaneseHolidayStab do
  @moduledoc false

  def load_fixture! do
    File.read!("test/fixtures/holidays.csv")
  end

  defmacro __using__(_) do
    quote do
      setup(context) do
        status = Map.get(context, :status, 200)

        response =
          Map.get(context, :response) ||
            :iconv.convert("utf-8", "cp932", JapaneseHolidayStab.load_fixture!())

        Req.Test.stub(JapaneseHoliday.WebAPI, fn conn ->
          conn
          |> Plug.Conn.put_status(status)
          |> Req.Test.text(response)
        end)
      end
    end
  end
end
