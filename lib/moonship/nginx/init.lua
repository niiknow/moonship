auto_ssl = (require("resty.auto-ssl")).new()
cname_dns = require("moonship.cname")
router_cache = require("moonship.routercache")
local base_host = os.getenv("BASE_HOST") or "moonship.test"
auto_ssl:set("allow_domain", function(domain)
  local host = domain
  local parts = string_split(domain, ".")
  if (#parts < 3) then
    host = "www." .. domain
  end
  local answers, err = cname_dns.resolve(host)
  if err then
    ngx.status = 500
    ngx.say(err)
    ngx.exit(ngx.status)
    return false
  end
  if not answers then
    ngx.status = 500
    ngx.say("failed to query the DNS server: ", err)
    ngx.exit(ngx.status)
    return false
  end
  for i, ans in ipairs(answers) do
    if ans.base == base_host then
      return true
    end
  end
  ngx.status = 500
  ngx.say("failed to query valid CNAME from DNS server")
  ngx.exit(ngx.status)
  return false
end)
auto_ssl:set("dir", "/usr/local/openresty/nginx/conf/ssl")
return auto_ssl:init()
