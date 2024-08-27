import Config

config :japanese_holiday, :api_req_options, plug: {Req.Test, JapaneseHoliday.API}
