
util         = require "moonship.util"
oauth1       = require "moonship.oauth1"

import concat from table
import query_string_encode from util

ltn12        = require "ltn12"
string_upper = string.upper
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
    opts["body"] = (type(opts["body"]) == "table") and query_string_encode(opts["body"]) or opts["body"]
    opts.headers["Content-Length"] = strlen(opts["body"] or "")

  opts.headers["Authorization"] = "Basic #{encode_base64(concat(opts.auth, '\n'))}" if opts["auth"]
  opts.headers["Authorization"] = oauth1.create_signature opts, opts["oauth"] if opts["oauth"]

  return http_handler.request(opts) if ngx

  resp = {}
  body = ""
  opts.sink = ltn12.sink.table(resp)
  one, code, headers, status = http_handler.request(opts)
  body = concat(resp) if one

  {:body, :code, :headers, :status }

{ :request }
