local engine = require("moonship.engine")
local ngin = engine.Engine({
  userS3 = true
})
local rst = ngin:engage()
local log = require("moonship.log")
log.level(log.DEBUG)
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
