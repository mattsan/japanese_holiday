defmodule JapaneseHolidayStab do
  @moduledoc false

  def setup(context) do
    status = Map.get(context, :status, 200)
    response = Map.fetch!(context, :response)

    Req.Test.stub(JapaneseHoliday.WebAPI, fn conn ->
      conn
      |> Plug.Conn.put_status(status)
      |> Req.Test.text(response)
    end)
  end
end
