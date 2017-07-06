engine = require "moonship.engine"
ngin = engine.Engine({userS3: true})
rst = ngin\engage()

log =  require "moonship.log"

log.level(log.DEBUG)

if rst
  ngx.status = rst.code

  -- send headers
  if (rst.headers)
    for v, k in ipairs rst.headers do
      ngx.header[k] = v

  ngx.say rst.body if (rst.body)

  ngx.exit(rst.code)
