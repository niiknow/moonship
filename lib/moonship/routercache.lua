local lrucache = require("resty.lrucache")
local util = require("mooncrafts.util")
local Router = require("mooncrafts.nginx.router")
local string_split
string_split = util.string_split
local CACHE_SIZE = 10000
local ROUTER_TTL = 3600
local cache, err = lrucache.new(CACHE_SIZE)
if (not cache) then
  return nil, error("failed to create the cache: " .. (err or "unknown"))
end
local resolve
resolve = function(app_dns)
  local router = cache:get(app_dns.name)
  if router then
    return router
  end
  opts.aws.request_path = "/" .. tostring(opts.aws.aws_s3_path) .. "/" .. tostring(full_path)
  local aws = aws_auth(opts.aws)
  local full_path = "https://" .. tostring(aws.options.aws_host) .. "/" .. tostring(app_dns.name) .. "/private/web.json"
  local authHeaders = aws:get_auth_headers()
  local req = {
    url = full_path,
    method = "GET",
    capture_url = "/__private",
    headers = { }
  }
  for k, v in pairs(authHeaders) do
    req.headers[k] = v
  end
  local res
  res, err = httpc.request(req)
  if err then
    ngx.status = 500
    ngx.say("failed to query website configuration file ", err)
    return ngx.exit(ngx.status)
  end
  local config = util.to_json(res.body)
  router = Router(config)
  cache:set(app_dns.name, router, ROUTER_TTL)
  return router
end
return {
  resolve = resolve
}
