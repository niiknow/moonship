local __sitename = ngx.var.__sitename
local router = router_cache.resolve(__sitename)
if router then
  return router:handleRequest(ngx)
end
ngx.status = 500
ngx.say("Unexpected error while handling request, this should be a 404")
return ngx.exit(ngx.status)
