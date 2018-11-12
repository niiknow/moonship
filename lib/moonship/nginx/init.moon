-- global define dns and auto ssl
export auto_ssl  = (require "resty.auto-ssl").new()
export cname_dns = require "moonship.cname"
export router_cache = require "moonship.routercache"

-- capture base host from env variable
base_host = os.getenv("BASE_HOST") or "moonship.test"

-- use dns to lookup valid cname
auto_ssl\set "allow_domain", (domain) ->
  -- lookup dns
  host  = domain
  parts = string_split(domain, ".")
  host  = "www." .. domain if (#parts < 3)
  answers, err = cname_dns.resolve(host)

  if err
    ngx.status = 500
    ngx.say(err)
    ngx.exit(ngx.status)
    return false

  if not answers
    ngx.status = 500
    ngx.say("failed to query the DNS server: ", err)
    ngx.exit(ngx.status)
    return false

  -- at least one cname must match base host
  for i, ans in ipairs(answers) do
    if ans.base == base_host
      return true

  ngx.status = 500
  ngx.say("failed to query valid CNAME from DNS server")
  ngx.exit(ngx.status)
  return false

auto_ssl\set("dir", "/app/ssl")
auto_ssl\init()
