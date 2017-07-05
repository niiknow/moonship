engine = require "moonscript.engine"
ngin = engine.Engine()
rst = ngin\engage(ngx.req)

-- send headers
if (rst.headers)
  for v, k in ipairs rst.headers do
    ngx.header[k] = v

ngx.say rst.body if (rst.body)
