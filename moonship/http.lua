local util = require("moonship.util")
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
    opts["Content-Length"] = strlen(opts["body"] or "")
  end
  if not (ngx) then
    local resultChunks = { }
    local body = ""
    opts.sink = ltn12.sink.table(resultChunks)
    local one, code, headers, status, x = http_handler.request(opts)
    if one then
      body = concat(resultChunks)
    end
    return {
      body = body,
      code = code,
      headers = headers,
      status = status
    }
  end
  return http_handler.request(opts)
end
return {
  request = request
}
