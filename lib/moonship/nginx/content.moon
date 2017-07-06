engine = require "moonship.engine"

log =  require "moonship.log"

log.level(log.DEBUG)

ngin = engine.Engine({useS3: true})
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
