engine = require "moonship.engine"

log =  require "moonship.log"

log.level(log.DEBUG)

ngin = engine.Engine {
  useS3: true,
  plugins: {
    awsauth: require "moonship.plugins.awsauth",
    azureauth: require "moonship.plugins.azureauth",
    crypto: require "moonship.plugins.crypto",
    hmacauth: require "moonship.plugins.hmacauth",
    http: require "moonship.plugins.http",
    jwt: require "moonship.plugins.jwt",
    log: require "moonship.plugins.log",
    oauth1: require "moonship.plugins.oauth1",
    require: require "moonship.plugins.require",
    request: require "moonship.plugins.request",
    util: require "moonship.plugins.util"
  }
}
rst = ngin\engage()

if rst
  log.debug "hi"
  ngx.status = rst.code

  -- send headers
  if (rst.headers)
    for k, v in ipairs rst.headers do
      ngx.header[k] = v

  ngx.say rst.body if (rst.body)

  ngx.exit(rst.code)
