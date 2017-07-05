local ngin = require "sngin.ngin"

local rsp = ngin.require_new("github.com/anvaka/redis-load-scripts/blob/master/test/scripts/nested/main.lua")
ngx.say(rsp[1])
ngx.exit(200)