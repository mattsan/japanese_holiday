import Config

config :japanese_holiday, :api_req_options, plug: {Req.Test, JapaneseHoliday.WebAPI}

config :logger, level: :warning
