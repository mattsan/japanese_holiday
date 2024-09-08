defmodule JapaneseHoliday.StorageTest do
  use ExUnit.Case

  alias JapaneseHoliday.{API, Storage}

  doctest Storage

  @moduletag :tmp_dir
  @csv_data "国民の祝日・休日月日,国民の祝日・休日名称\r\n2024/1/1,元日\r\n"

  defp respond_csv(context) do
    Req.Test.stub(API, fn conn ->
      response = Map.get(context, :response, @csv_data)

      conn
      |> Plug.Conn.put_status(200)
      |> Req.Test.text(:iconv.convert("utf-8", "cp932", response))
    end)
  end

  defp create_csv_file(context) do
    File.write(context.path, @csv_data)
  end

  defp on_exit_remove_file(context) do
    on_exit(fn -> File.rm!(context.path) end)
  end

  setup(context) do
    path = Path.join(context.tmp_dir, "holiday.csv")

    [path: path]
  end

  describe "load/1" do
    setup [:respond_csv, :on_exit_remove_file]

    test "ダウンロードした CSV データを返すこと、ファイルに保存すること", %{path: path} do
      refute File.exists?(path)
      assert Storage.load(path) == {:ok, "国民の祝日・休日月日,国民の祝日・休日名称\r\n2024/1/1,元日\r\n"}
      assert File.read(path) == {:ok, "国民の祝日・休日月日,国民の祝日・休日名称\r\n2024/1/1,元日\r\n"}
    end
  end

  describe "load/2 save: false が設定された場合" do
    setup [:respond_csv]

    test "ダウンロードした CSV データを返すこと、ファイルに保存しないこと", %{path: path} do
      refute File.exists?(path)
      assert Storage.load(path, save: false) == {:ok, "国民の祝日・休日月日,国民の祝日・休日名称\r\n2024/1/1,元日\r\n"}
      refute File.exists?(path)
    end
  end

  describe "load/1 保存したファイルが存在する場合" do
    setup [:create_csv_file]

    test "CSV データをダウンロードせず、ファイルの内容を返すこと", %{path: path} do
      Req.Test.stub(API, fn _ ->
        flunk("Unexpected download is occoured.")
      end)

      assert File.exists?(path)
      assert Storage.load(path) == {:ok, "国民の祝日・休日月日,国民の祝日・休日名称\r\n2024/1/1,元日\r\n"}
    end
  end

  describe "load/2 保存したファイルが存在する場合 force: true が指定された場合" do
    setup [:create_csv_file, :respond_csv]

    @tag response: "date,name\r\n2024/1/1,元日\r\n"

    test "CSV データがダウンロードされること、ファイルの内容がダウンロードされた内容に更新されること", %{path: path} do
      assert File.read(path) == {:ok, "国民の祝日・休日月日,国民の祝日・休日名称\r\n2024/1/1,元日\r\n"}
      assert Storage.load(path, force: true) == {:ok, "date,name\r\n2024/1/1,元日\r\n"}
      assert File.read(path) == {:ok, "date,name\r\n2024/1/1,元日\r\n"}
    end
  end
end
