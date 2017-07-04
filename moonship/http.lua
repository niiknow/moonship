local util = require("moonship.util")
local oauth1 = require("moonship.oauth1")
local concat
concat = table.concat
local query_string_encode
query_string_encode = util.query_string_encode
local ltn12 = require("ltn12")
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
      error = "url is required"
    }
  end
  opts["method"] = string_upper(opts["method"] or 'GET')
  opts["headers"] = opts["headers"] or {
    ["Accept"] = "*/*"
  }
  opts["headers"]["User-Agent"] = opts["headers"]["User-Agent"] or "Mozilla/5.0"
  if opts.source then
    local buff = { }
    local sink = ltn12.sink.table(buff)
    ltn12.pump.all(req.source, sink)
    local body = concat(buff)
    opts["body"] = body
  end
  if opts["body"] then
    opts["body"] = (type(opts["body"]) == "table") and query_string_encode(opts["body"]) or opts["body"]
    opts.headers["Content-Length"] = strlen(opts["body"] or "")
  end
  if opts["auth"] then
    opts.headers["Authorization"] = "Basic " .. tostring(encode_base64(concat(opts.auth, '\n')))
  end
  if opts["oauth"] then
    opts.headers["Authorization"] = oauth1.create_signature(opts, opts["oauth"])
  end
  if ngx then
    return http_handler.request(opts)
  end
  local resp = { }
  local body = ""
  opts.sink = ltn12.sink.table(resp)
  local one, code, headers, status = http_handler.request(opts)
  if one then
    body = concat(resp)
  end
  return {
    body = body,
    code = code,
    headers = headers,
    status = status
  }
end
return {
  request = request
}
