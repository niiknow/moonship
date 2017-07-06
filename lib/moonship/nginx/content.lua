local engine = require("moonship.engine")
local log = require("moonship.log")
log.level(log.DEBUG)
local ngin = engine({
  useS3 = true,
  plugins = {
    awsauth = require("moonship.plugins.awsauth"),
    azureauth = require("moonship.plugins.azureauth"),
    crypto = require("moonship.plugins.crypto"),
    hmacauth = require("moonship.plugins.hmacauth"),
    http = require("moonship.plugins.http"),
    jwt = require("moonship.plugins.jwt"),
    log = require("moonship.plugins.log"),
    oauth1 = require("moonship.plugins.oauth1"),
    require = require("moonship.plugins.require"),
    request = require("moonship.plugins.request"),
    util = require("moonship.plugins.util")
  }
})
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
