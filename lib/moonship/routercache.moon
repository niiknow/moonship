-- cache route to dns host
lrucache = require "resty.lrucache"
util     = require "mooncrafts.util"
Router  = require "mooncrafts.nginx.router"

import string_split from util

CACHE_SIZE = 10000
ROUTER_TTL = 3600

cache, err = lrucache.new(CACHE_SIZE)

return nil, error("failed to create the cache: " .. (err or "unknown")) if (not cache)

resolve = (name) ->
  router = cache\get(name)
  return router if router

  -- attempt to resolve router web.json
  opts.aws.request_path = "/#{opts.aws.aws_s3_path}/#{full_path}"
  aws = aws_auth(opts.aws)
  full_path = "https://#{aws.options.aws_host}/#{name}/private/web.json"
  authHeaders = aws\get_auth_headers()

  req = { url: full_path, method: "GET", capture_url: "/__private", headers: {} }

  for k, v in pairs(authHeaders) do
    req.headers[k] = v

  -- ngx.log(ngx.ERR, 'req' .. util.to_json(req))
  res, err = httpc.request(req)

  if err
    ngx.status = 500
    ngx.say("failed to query website configuration file ", err)
    return ngx.exit(ngx.status)

  -- parse json
  config = util.to_json(res.body)
  router = Router(config)

  cache\set(name, router, ROUTER_TTL)
  router

{ :resolve }
