http_handler = ngx and require "moonship.nginx.http" or require "socket.http"
util         = require "moonship.util"
string_upper = string.upper
qs_encode    = util.query_string_encode

local *
request = (opts) ->
  if type(opts) == 'string' then
    opts = { url: opts, method: 'GET' }

  unless opts.url
    opts["method"] = string_upper(opts["method"] or 'GET')
    opts["headers"] = opts["headers"] or {["Accept"]: "*/*"}
    opts["headers"]["User-Agent"] = opts["headers"]["User-Agent"] or "Mozilla/5.0"

    -- auto add content length
    if opts["body"] then
      opts["body"] = (type(opts["body"]) == "table") and qs_encode(opts["body"]) or opts["body"]
      opts["Content-Length"] = strlen(opts["body"] or "")

    return http_handler.request(opts)

  { code: 0, error: "url is required" }

{
  :request
}
