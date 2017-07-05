
util         = require "moonship.util"
oauth1       = require "moonship.oauth1"
http         = require "httpclient"
has_zlib, zlib = pcall(require, "zlib")

import concat from table
import query_string_encode from util

string_upper = string.upper
http_handler = (ngx and require "moonship.nginx.http") or require "http.compat.socket"

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

  hc = http.new()

  opts["method"] = string_upper(opts["method"] or 'GET')
  opts["headers"] = opts["headers"] or {["Accept"]: "*/*"}
  opts["headers"]["User-Agent"] = opts["headers"]["User-Agent"] or "Mozilla/5.0"

  -- auto add content length
  if opts["body"]
    opts["body"] = (type(opts["body"]) == "table") and query_string_encode(opts["body"]) or opts["body"]

  opts.headers["Authorization"] = "Basic #{encode_base64(concat(opts.auth, '\n'))}" if opts["auth"]
  opts.headers["Authorization"] = oauth1.create_signature opts, opts["oauth"] if opts["oauth"]

  opts.ssl_opts = {verify: "none"} unless opts["ssl_opts"]

  if has_zlib then
    opts.headers["accept-encoding"] = "gzip, deflate"

  if ngx and opts.capture_url
    hc = http.new('httpclient.ngx_driver')
    hc\set_default('capture_url', opts.capture_url)
    hc\set_default('capture_variable', opts.capture_variable or "url")

  util.applyDefaults(opts, hc\get_defaults())
  params = opts.params or nil

  res = hc.client\request(opts.url, params, opts.method, opts)
  if has_zlib and res.body
    encoding = res.headers["content-encoding"] or ""
    deflated = encoding\find("deflate")
    gziped = encoding\find("gzip")
    bodys = res.body
    if (gziped or deflated)
      stream = zlib.inflate()
      status, output, eof, bytes_in, bytes_out = pcall(stream, bodys)
      res.body = output

  res
{ :request }
