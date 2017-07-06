engine = require "moonship.engine"
ngin = engine.Engine()
rst = ngin\engage(ngx.req)

if rst
  ngx.status = rst.code

  -- send headers
  if (rst.headers)
    for v, k in ipairs rst.headers do
      ngx.header[k] = v

  ngx.say rst.body if (rst.body)

  ngx.exit(rst.code)
