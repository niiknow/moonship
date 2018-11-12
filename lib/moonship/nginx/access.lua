local host = ngx.var.host
local parts = string_split(host, ".")
if (#parts < 3) then
  host = "www." .. host
end
local answers, err = cname_dns.resolve(host)
ngx.var.__sitename = nil
if err then
  ngx.status = 403
  ngx.say(err)
  return ngx.exit(ngx.status)
end
if not answers then
  ngx.status = 403
  ngx.say("failed to query the DNS server: ", err)
  return ngx.exit(ngx.status)
end
for i, ans in ipairs(answers) do
  if ans.base == base_host then
    ngx.var.__sitename = ans.name
    local router = router_cache.resolve(__sitename)
    if router then
      return true
    end
  end
end
ngx.status = 403
ngx.say("failed to query valid CNAME from DNS server")
return ngx.exit(ngx.status)
