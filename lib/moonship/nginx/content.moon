engine = require "moonship.engine"
ngin = engine.Engine({useS3: true})
rst = ngin\engage()

log =  require "moonship.log"

if rst
  ngx.status = rst.code

  -- send headers
  if (rst.headers)
    for k, v in ipairs rst.headers do
      ngx.header[k] = v

  ngx.say rst.body if (rst.body)

  ngx.exit(rst.code)
