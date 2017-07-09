local log = require("moonship.log")
log.level(log.DEBUG)
local engine = require("moonship.engine")
local awsauth = require("moonship.awsauth")
local azts = require("moonship.aztablestategy")
local util = require("moonship.util")
local crypto = require("moonship.crypto")
local hmacauth = require("moonship.hmacauth")
local http = require("moonship.http")
local logger = require("moonship.logger")
local oauth1 = require("moonship.oauth1")
local request = require("moonship.plugins.request")
local table_clone
table_clone = util.table_clone
local opts = {
  useS3 = true,
  plugins = {
    awsauth = awsauth,
    azauth = table_clone(azts.azauth),
    crypto = table_clone(crypto),
    hmacauth = table_clone(hmacauth),
    http = table_clone(http),
    log = logger(),
    oauth1 = table_clone(oauth1),
    request = request,
    util = table_clone(util)
  }
}
local ngin = engine(opts)
local rst = ngin:engage()
if rst then
  log.debug("hi")
  ngx.status = rst.code
  if (rst.headers) then
    for k, v in ipairs(rst.headers) do
      ngx.header[k] = v
    end
  end
  if (rst.body) then
    ngx.say(rst.body)
  end
  return ngx.exit(rst.code)
end
