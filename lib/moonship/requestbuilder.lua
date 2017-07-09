local sandbox = require("moonship.sandbox")
local request, build, set
request = { }
build = function(opts)
  if ngx then
    ngx.req.read_body()
    local req_wrapper = {
      body = ngx.req.get_body_data(),
      form = ngx.req.get_post_args(),
      headers = ngx.req.get_headers(),
      host = ngx.var.host,
      method = ngx.req.get_method(),
      path = ngx.var.uri,
      port = ngx.var.server_port,
      query = ngx.req.get_uri_args(),
      querystring = ngx.req.args,
      remote_addr = ngx.var.remote_addr,
      referer = ngx.var.http_referer or "-",
      scheme = ngx.var.scheme,
      server_addr = ngx.var.server_addr,
      user_agent = ""
    }
    req_wrapper.user_agent = req_wrapper.headers["User-Agent"]
    return req_wrapper
  end
  return request
end
set = function(req)
  request = req
end
return {
  build = build,
  set = set
}
