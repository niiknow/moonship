local engine = require("moonship.engine")
local ngin = engine.Engine()
local rst = ngin:engage(ngx.req)
if rst then
  ngx.status = rst.code
  if (rst.headers) then
    for v, k in ipairs(rst.headers) do
      ngx.header[k] = v
    end
  end
  if (rst.body) then
    ngx.say(rst.body)
  end
  return ngx.exit(rst.code)
end
