-- get the app content
__sitename = ngx.var.__sitename
router = router_cache.resolve(__sitename)

if router
  return router\handleRequest(ngx)

ngx.status = 500
ngx.say("Unexpected error while handling request, this should be a 404")
ngx.exit(ngx.status)
