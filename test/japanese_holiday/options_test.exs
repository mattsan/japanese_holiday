defmodule JapaneseHoliday.OptionsTest do
  use ExUnit.Case
  alias JapaneseHoliday.Options
  doctest Options

  describe "parse/1" do
    test "オプションを指定しない場合、デフォルトの値を返すこと" do
      expected =
        {
          :ok,
          %Options{
            url: "https://www8.cao.go.jp/chosei/shukujitsu/syukujitsu.csv",
            path: nil,
            save?: false,
            force?: false,
            encoding: "cp932"
          }
        }

      assert expected == Options.parse([])
    end

    test "URL を指定した場合、オプションの url に反映されること" do
      expected =
        {
          :ok,
          %Options{
            url: "https://example.com/holidays.csv",
            path: nil,
            save?: false,
            force?: false,
            encoding: "cp932"
          }
        }

      assert expected == Options.parse(url: "https://example.com/holidays.csv")
    end

    test "ファイルパスを指定した場合、オプションの path に反映されること" do
      expected =
        {
          :ok,
          %Options{
            url: "https://www8.cao.go.jp/chosei/shukujitsu/syukujitsu.csv",
            path: "path/to/something.csv",
            save?: false,
            force?: false,
            encoding: "cp932"
          }
        }

      assert expected == Options.parse(path: "path/to/something.csv")
    end

    test "ファイルパスを指定せず、ファイルへの保存を指定した場合、エラーを返すこと" do
      expected =
        {
          :error,
          {:path_must_be_string_if_to_save, [save: true, path: nil]}
        }

      assert expected == Options.parse(save: true)
    end

    test "ファイルパスを指定し、ファイルへの保存を指定した場合、オプションの path, save? に反映されること" do
      expected =
        {
          :ok,
          %Options{
            url: "https://www8.cao.go.jp/chosei/shukujitsu/syukujitsu.csv",
            path: "path/to/something.csv",
            save?: true,
            force?: false,
            encoding: "cp932"
          }
        }

      assert expected == Options.parse(path: "path/to/something.csv", save: true)
    end

    test "強制ダウンロードを指定した場合、オプションの force? に反映されること" do
      expected =
        {
          :ok,
          %Options{
            url: "https://www8.cao.go.jp/chosei/shukujitsu/syukujitsu.csv",
            path: nil,
            save?: false,
            force?: true,
            encoding: "cp932"
          }
        }

      assert expected == Options.parse(force: true)
    end

    test "エンコーディングを指定した場合、オプションの encoding に反映されること" do
      expected =
        {
          :ok,
          %Options{
            url: "https://www8.cao.go.jp/chosei/shukujitsu/syukujitsu.csv",
            path: nil,
            save?: false,
            force?: false,
            encoding: "utf8"
          }
        }

      assert expected == Options.parse(encoding: "utf8")
    end

    test "不明なオプションを指定した場合、エラーを返すこと" do
      expected =
        {
          :error,
          {:unknown_options, [:foo, :bar]}
        }

      assert expected == Options.parse(foo: "foo", bar: 123)
    end
  end
end
