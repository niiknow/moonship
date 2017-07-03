local http_handler = ngx and require("moonship.nginx.http" or require("socket.http"))
local util = require("moonship.util")
local string_upper = string.upper
local qs_encode = util.query_string_encode
local request
request = function(opts)
  if type(opts) == 'string' then
    opts = {
      url = opts,
      method = 'GET'
    }
  end
  if not (opts.url) then
    opts["method"] = string_upper(opts["method"] or 'GET')
    opts["headers"] = opts["headers"] or {
      ["Accept"] = "*/*"
    }
    opts["headers"]["User-Agent"] = opts["headers"]["User-Agent"] or "Mozilla/5.0"
    if opts["body"] then
      opts["body"] = (type(opts["body"]) == "table") and qs_encode(opts["body"]) or opts["body"]
      opts["Content-Length"] = strlen(opts["body"] or "")
    end
    return http_handler.request(opts)
  end
  return {
    code = 0,
    error = "url is required"
  }
end
return {
  request = request
}
