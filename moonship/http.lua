local util = require("moonship.util")
local oauth1 = require("moonship.oauth1")
local http = require("httpclient")
local has_zlib, zlib = pcall(require, "zlib")
local concat
concat = table.concat
local query_string_encode
query_string_encode = util.query_string_encode
local string_upper = string.upper
local http_handler = (ngx and require("moonship.nginx.http")) or require("http.compat.socket")
local request
request = function(opts)
  if type(opts) == 'string' then
    opts = {
      url = opts,
      method = 'GET'
    }
  end
  if not (opts.url) then
    return {
      code = 0,
      err = "url is required"
    }
  end
  local hc = http.new()
  opts["method"] = string_upper(opts["method"] or 'GET')
  opts["headers"] = opts["headers"] or {
    ["Accept"] = "*/*"
  }
  opts["headers"]["User-Agent"] = opts["headers"]["User-Agent"] or "Mozilla/5.0"
  if opts["body"] then
    opts["body"] = (type(opts["body"]) == "table") and query_string_encode(opts["body"]) or opts["body"]
  end
  if opts["auth"] then
    opts.headers["Authorization"] = "Basic " .. tostring(encode_base64(concat(opts.auth, '\n')))
  end
  if opts["oauth"] then
    opts.headers["Authorization"] = oauth1.create_signature(opts, opts["oauth"])
  end
  if not (opts["ssl_opts"]) then
    opts.ssl_opts = {
      verify = "none"
    }
  end
  if has_zlib then
    opts.headers["accept-encoding"] = "gzip, deflate"
  end
  if ngx and opts.capture_url then
    hc = http.new('httpclient.ngx_driver')
    hc:set_default('capture_url', opts.capture_url)
    hc:set_default('capture_variable', opts.capture_variable or "url")
  end
  util.applyDefaults(opts, hc:get_defaults())
  local params = opts.params or nil
  local res = hc.client:request(opts.url, params, opts.method, opts)
  if has_zlib and res.body then
    local encoding = res.headers["content-encoding"] or ""
    local deflated = encoding:find("deflate")
    local gziped = encoding:find("gzip")
    local bodys = res.body
    if (gziped or deflated) then
      local stream = zlib.inflate()
      local status, output, eof, bytes_in, bytes_out = pcall(stream, bodys)
      res.body = output
    end
  end
  return res
end
return {
  request = request
}
