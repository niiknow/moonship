
util         = require "moonship.util"
oauth1       = require "moonship.oauth1"

ltn12        = require "ltn12"
string_upper = string.upper
http_handler = nil

-- http.compat.socket is for local testing only, it doesn't work with openresty
-- Failed installing dependency: https://luarocks.org/compat53-0.3-1.src.rock - Build error: Failed compiling object ltablib.o
http_handler = require "moonship.nginx.http" if ngx
http_handler = require "http.compat.socket" unless ngx

has_zlib, zlib = pcall(require, "zlib")

import concat from table
import query_string_encode from util

string_upper = string.upper

--{
--  body = <response body>,
--  code = <http status code>,
--  headers = <table of headers>,
--  status_line = <the http status message>,
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
  if opts["body"]
    opts["body"] = (type(opts["body"]) == "table") and query_string_encode(opts["body"]) or opts["body"]

  opts.headers["Authorization"] = "Basic #{encode_base64(concat(opts.auth, '\n'))}" if opts["auth"]
  opts.headers["Authorization"] = oauth1.create_signature opts, opts["oauth"] if opts["oauth"]

  opts.ssl_opts = {verify: "none"} unless opts["ssl_opts"]

  unless ngx
    if has_zlib then
      opts.headers["accept-encoding"] = "gzip, deflate"

    resultChunks = {}
    body = ""
    opts.sink = ltn12.sink.table(resultChunks)
    one, code, headers, status = http_handler.request(opts)
    body = concat(resultChunks) if one

    res =  {:body, :code, :headers, :status }

    if has_zlib and res.body
      encoding = res.headers["content-encoding"] or ""
      deflated = encoding\find("deflate")
      gziped = encoding\find("gzip")
      bodys = res.body
      if (gziped or deflated)
        stream = zlib.inflate()
        status, output, eof, bytes_in, bytes_out = pcall(stream, bodys)
        res.body = output

    return res

  http_handler.request(opts)

{ :request }
