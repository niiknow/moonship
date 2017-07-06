local util = require("moonship.util")
local oauth1 = require("moonship.oauth1")
local ltn12 = require("ltn12")
local string_upper = string.upper
local http_handler = require("moonship.nginx.http")
if not (ngx) then
  http_handler = require("http.compat.socket")
end
local has_zlib, zlib = pcall(require, "zlib")
local concat
concat = table.concat
local query_string_encode
query_string_encode = util.query_string_encode
string_upper = string.upper
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
  if not (ngx) then
    local resultChunks = { }
    local body = ""
    opts.sink = ltn12.sink.table(resultChunks)
    local one, code, headers, status = http_handler.request(opts)
    if one then
      body = concat(resultChunks)
    end
    local res = {
      body = body,
      code = code,
      headers = headers,
      status = status
    }
    if has_zlib and res.body then
      local encoding = res.headers["content-encoding"] or ""
      local deflated = encoding:find("deflate")
      local gziped = encoding:find("gzip")
      local bodys = res.body
      if (gziped or deflated) then
        local stream = zlib.inflate()
        local output, eof, bytes_in, bytes_out
        status, output, eof, bytes_in, bytes_out = pcall(stream, bodys)
        res.body = output
      end
    end
    return res
  end
  return http_handler.request(opts)
end
return {
  request = request
}
