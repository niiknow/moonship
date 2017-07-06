local hmacauth = require("moonship.hmacauth")
local base64_encode = (require("moonship.util")).base64_encode
local _ = {
  date_utc = function(date)
    if date == nil then
      date = os.time()
    end
    return os.date("!%a, %d, %b, %Y %H:%M:%S GMT", date)
  end
}
_ = {
  sharedkeylite = function(opts)
    if opts == nil then
      opts = {
        account_name = account_name,
        account_key = account_key,
        table_name = table_name
      }
    end
    opts.date = opts.date or date_utc()
    opts.sig = base64_encode(opts.account_key, tostring(opts.date) .. "\n/" .. tostring(opts.account_name) .. "/" .. tostring(opts.table_name))
    return opts
  end
}
return {
  date_utc = date_utc,
  sharedkeylite = sharedkeylite
}
