-- validate host by dns
host = ngx.var.host
parts = string_split(host, ".")
host  = "www." .. host if (#parts < 3)
answers, err = cname_dns.resolve(host)

-- empty sitename to prevent issue
ngx.var.__sitename = nil

if err
  ngx.status = 403
  ngx.say(err)
  return ngx.exit(ngx.status)

if not answers
  ngx.status = 403
  ngx.say("failed to query the DNS server: ", err)
  return ngx.exit(ngx.status)

-- at least one cname must match base host
for i, ans in ipairs(answers) do
  if ans.base == base_host
    ngx.var.__sitename = ans.name
    -- capture the config
    router = router_cache.resolve(__sitename)
    return true if router

ngx.status = 403
ngx.say("failed to query valid CNAME from DNS server")
return ngx.exit(ngx.status)
