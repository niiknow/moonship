log               =  require "moonship.logger"
log.set_lvl("info")

engine            = require "moonship.engine"
awsauth           = require "moonship.awsauth"
azts              = require "moonship.aztablestategy"
util              = require "moonship.util"
crypto            = require "moonship.crypto"
hmacauth          = require "moonship.hmacauth"
http              = require "moonship.http"
logger            = require "moonship.logger"
oauth1            = require "moonship.oauth1"
requestbuilder    = require "moonship.requestbuilder"

import table_clone from util

opts = {
  useS3: true,
  requestbuilder: requestbuilder,
  plugins: {
    awsauth: awsauth,
    azauth: table_clone(azts.azauth),
    crypto: table_clone(crypto),
    hmacauth: table_clone(hmacauth),
    http: table_clone(http),
    oauth1: table_clone(oauth1),
    util: table_clone(util)
  }
}
ngin = engine opts


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
