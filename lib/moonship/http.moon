
util         = require "moonship.util"
oauth1       = require "moonship.oauth1"

string_upper = string.upper
http_handler = require "moonship.httpsocket"
http_handler = require "moonship.nginx.http" if ngx

import concat from table
import query_string_encode from util

string_upper = string.upper

--{
--  body = <response body>,
--  code = <http status code>,
--  headers = <table of headers>,
--  status = <the http status message>,
--  err = <nil or error message>
-- }
local *
request = (opts) ->

  opts = { url: opts, method: 'GET' } if type(opts) == 'string'

  return { code: 0, err: "url is required" } unless opts.url

  opts["method"] = string_upper(opts["method"] or 'GET')
  opts["headers"] = opts["headers"] or {["Accept"]: "*/*"}
  opts["headers"]["User-Agent"] = opts["headers"]["User-Agent"] or "Mozilla/5.0"

  -- auto add content length
  body = opts["body"]
  if body
    body = (type(body) == "table") and query_string_encode(body) or body
    opts.body = body
    opts.headers["content-length"] = #body

  opts.headers["Authorization"] = "Basic #{encode_base64(concat(opts.auth, ':'))}" if opts["auth"]
  opts.headers["Authorization"] = oauth1.create_signature opts, opts["oauth"] if opts["oauth"]

  http_handler.request(opts)

{ :request }
