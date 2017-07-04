import concat from table
ltn12 = require('ltn12')
util         = require "moonship.util"
string_upper = string.upper
qs_encode    = util.query_string_encode
http_handler = (ngx and require "moonship.nginx.http") or require "http.compat.socket"

local *
request = (opts) ->

  opts = { url: opts, method: 'GET' } if type(opts) == 'string'

  return { code: 0, error: "url is required" } unless opts.url

  opts["method"] = string_upper(opts["method"] or 'GET')
  opts["headers"] = opts["headers"] or {["Accept"]: "*/*"}
  opts["headers"]["User-Agent"] = opts["headers"]["User-Agent"] or "Mozilla/5.0"

  if opts.source
    buff = { }
    sink = ltn12.sink.table(buff)
    ltn12.pump.all(req.source, sink)
    body = concat(buff)
    opts["body"] = body


  -- auto add content length
  if opts["body"]
    opts["body"] = (type(opts["body"]) == "table") and qs_encode(opts["body"]) or opts["body"]
    opts["Content-Length"] = strlen(opts["body"] or "")


  unless ngx
    resultChunks = {}
    body = ""
    opts.sink = ltn12.sink.table(resultChunks)
    one, code, headers, status, x = http_handler.request(opts)
    body = concat(resultChunks) if one

    return {:body, :code, :headers, :status }


  http_handler.request(opts)
{
  :request
}
