local engine = require("moonscript.engine")
local ngin = engine.Engine()
local rst = ngin:engage(ngx.req)
if (rst.headers) then
  for v, k in ipairs(rst.headers) do
    ngx.header[k] = v
  end
end
if (rst.body) then
  return ngx.say(rst.body)
end
