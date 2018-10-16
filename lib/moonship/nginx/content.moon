log               = require "mooncrafts.log"
log.set_lvl("info")

engine            = require "moonship.engine"
awsauth           = require "mooncrafts.awsauth"
azauth            = require "mooncrafts.azauth"
util              = require "mooncrafts.util"
crypto            = require "mooncrafts.crypto"
hmacauth          = require "mooncrafts.hmacauth"
http              = require "mooncrafts.http"
oauth1            = require "mooncrafts.oauth1"


import table_clone from util

opts = {
  useS3: true,
  plugins: {
    awsauth: awsauth,
    azauth: table_clone(azauth),
    crypto: table_clone(crypto),
    hmacauth: table_clone(hmacauth),
    http: table_clone(http),
    oauth1: table_clone(oauth1),
    util: table_clone(util)
  }
}
ngin = engine opts

rst = ngin\engage() or { code: 500, req: {} }

rst.req.end = os.time()

-- async logging

-- send status
ngx.status = rst.code

-- send headers
if (rst.headers)
  for k, v in pairs rst.headers do
    ngx.header[k] = v

-- ngx.log(ngx.ERR, util.to_json(rst))

-- send body
ngx.say rst.body if (rst.body)

-- make clean exit
ngx.exit(rst.code)

