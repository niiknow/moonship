local util = require("moonship.util")
local oauth1 = require("moonship.oauth1")
local string_upper = string.upper
local http_handler = require("moonship.httpsocket")
if ngx then
  http_handler = require("moonship.nginx.http")
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
  local body = opts["body"]
  if body then
    body = (type(body) == "table") and query_string_encode(body) or body
    opts.body = body
    opts.headers["content-length"] = #body
  end
  if opts["auth"] then
    opts.headers["Authorization"] = "Basic " .. tostring(encode_base64(concat(opts.auth, '\n')))
  end
  if opts["oauth"] then
    opts.headers["Authorization"] = oauth1.create_signature(opts, opts["oauth"])
  end
  return http_handler.request(opts)
end
return {
  request = request
}
