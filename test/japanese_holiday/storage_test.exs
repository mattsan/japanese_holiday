defmodule JapaneseHoliday.StorageTest do
  use ExUnit.Case
  use JapaneseHolidayStab
  alias JapaneseHoliday.{WebAPI, Storage}
  doctest Storage

  @url "https://example.com/syukujitsu.csv"

  @moduletag :tmp_dir
  @moduletag csv_data: "国民の祝日・休日月日,国民の祝日・休日名称\r\n2024/1/1,元日\r\n"

  defp create_csv_file(context) do
    File.write(context.path, context.csv_data)
  end

  defp on_exit_remove_file(context) do
    on_exit(fn -> File.rm!(context.path) end)
  end

  setup_all(context) do
    [response: :iconv.convert("utf-8", "cp932", context.csv_data)]
  end

  setup(context) do
    [path: Path.join(context.tmp_dir, "holiday.csv")]
  end

  describe "load/1" do
    setup [:on_exit_remove_file]

    test "ダウンロードした CSV データを返すこと、ファイルに保存すること", %{path: path} do
      options = [
        url: @url,
        path: path,
        encoding: "cp932",
        save: true
      ]

      refute File.exists?(path)
      assert Storage.load(options) == {:ok, "国民の祝日・休日月日,国民の祝日・休日名称\r\n2024/1/1,元日\r\n"}
      assert File.read(path) == {:ok, "国民の祝日・休日月日,国民の祝日・休日名称\r\n2024/1/1,元日\r\n"}
    end
  end

  describe "load/2 save: false が設定された場合" do
    test "ダウンロードした CSV データを返すこと、ファイルに保存しないこと", %{path: path} do
      options = [
        url: @url,
        path: path,
        encoding: "cp932",
        save: false
      ]

      refute File.exists?(path)
      assert Storage.load(options) == {:ok, "国民の祝日・休日月日,国民の祝日・休日名称\r\n2024/1/1,元日\r\n"}
      refute File.exists?(path)
    end
  end

  describe "load/1 保存したファイルが存在する場合" do
    setup [:create_csv_file]

    test "CSV データをダウンロードせず、ファイルの内容を返すこと", %{path: path} do
      options = [
        url: @url,
        path: path,
        encoding: "cp932"
      ]

      Req.Test.stub(WebAPI, fn _ -> flunk("Unexpected download is occoured.") end)
      assert File.exists?(path)
      assert Storage.load(options) == {:ok, "国民の祝日・休日月日,国民の祝日・休日名称\r\n2024/1/1,元日\r\n"}
    end
  end

  describe "load/2 保存したファイルが存在する場合 force: true が指定された場合" do
    setup [:create_csv_file]

    @tag response: :iconv.convert("utf-8", "cp932", "date,name\r\n2024/1/1,元日\r\n")
    test "CSV データがダウンロードされること、ファイルの内容がダウンロードされた内容に更新されること", %{path: path} do
      options = [
        url: @url,
        path: path,
        encoding: "cp932",
        force: true,
        save: true
      ]

      assert File.read(path) == {:ok, "国民の祝日・休日月日,国民の祝日・休日名称\r\n2024/1/1,元日\r\n"}
      assert Storage.load(options) == {:ok, "date,name\r\n2024/1/1,元日\r\n"}
      assert File.read(path) == {:ok, "date,name\r\n2024/1/1,元日\r\n"}
    end
  end
end
