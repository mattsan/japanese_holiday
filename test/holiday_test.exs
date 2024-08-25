defmodule HolidayTest do
  use ExUnit.Case
  doctest Holiday

  test "greets the world" do
    assert Holiday.hello() == :world
  end
end
