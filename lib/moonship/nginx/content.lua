local log = require("mooncrafts.log")
log.set_lvl("info")
local engine = require("moonship.engine")
local awsauth = require("mooncrafts.awsauth")
local azauth = require("mooncrafts.azauth")
local util = require("mooncrafts.util")
local crypto = require("mooncrafts.crypto")
local hmacauth = require("mooncrafts.hmacauth")
local http = require("mooncrafts.http")
local oauth1 = require("mooncrafts.oauth1")
local table_clone
table_clone = util.table_clone
local opts = {
  useS3 = true,
  plugins = {
    awsauth = awsauth,
    azauth = table_clone(azauth),
    crypto = table_clone(crypto),
    hmacauth = table_clone(hmacauth),
    http = table_clone(http),
    oauth1 = table_clone(oauth1),
    util = table_clone(util)
  }
}
local ngin = engine(opts)
local rst = ngin:engage() or {
  code = 500,
  req = { }
}
rst.req["end"] = os.time()
ngx.status = rst.code
if (rst.headers) then
  for k, v in pairs(rst.headers) do
    ngx.header[k] = v
  end
end
if (rst.body) then
  ngx.say(rst.body)
end
return ngx.exit(rst.code)
