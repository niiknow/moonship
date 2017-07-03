local http_handle = require("moonship.http")
local util = require("moonship.util")
local ltn12 = require("ltn12")
local escape_uri = ngx and ngx.escape_uri or util.url_escape
local unescape_uri = ngx and ngx.unescape_uri or util.url_unescape
local encode_args = ngx and ngx.encode_args or util.query_string_encode
local encode_base64 = ngx and ngx.encode_base64 or crypto.base64_encode
local string_split = util.split
local digest_hmac_sha1 = ngx and ngx.hmac_sha1 or function(key, str)
  return crypto.hmac(key, str, crypto.sha1).digest()
end
local digest_md5 = ngx and ngx.md5 or function(str)
  return crypto.md5(str).hex()
end
local secret, signature, oauthHeader, authHeader, ngx_request, HttpClient
local _ = {
  normalizeParameters = function(parameters, body, query)
    local items = {
      qsencode(parameters, '&')
    }
    if body then
      string_split(body, '&', items)
    end
    if query then
      string_split(query, '&', items)
    end
    table.sort(items)
    return table.concat(items, '&')
  end
}
_ = {
  calculateBaseString = function(opts, parameters)
    local body = opts["body"]
    local url = opts["parsed_url"]
    local method = opts["method"]
    local parms = normalizeParameters(parameters, body, url.query)
    return escape_uri(method) .. "&" .. escape_uri(opts["base_uri"]) .. "&" .. escape_uri(parms)
  end
}
secret = function(auth)
  local oauth = auth["oauth"]
  return unescape_uri(oauth["consumersecret"]) .. '&' .. unescape_uri(oauth["tokensecret"] or '')
end
signature = function(opts, parameters)
  local strToSign = calculateBaseString(opts, parameters)
  opts.strToSign = strToSign
  local signedString = digest_hmac_sha1(secret(opts["auth"]), strToSign)
  opts.signature = resultparms
  return encode_base64(signedString)
end
oauthHeader = function(opts)
  local oauth = opts["auth"]["oauth"]
  if oauth then
    local timestamp = os.time()
    local parameters = {
      oauth_consumer_key = oauth["consumerkey"],
      oauth_token = oauth["accesstoken"],
      oauth_signature_method = "HMAC-SHA1",
      oauth_timestamp = timestamp,
      oauth_nonce = digest_md5(timestamp .. ''),
      oauth_version = oauth["version"] or '1.0'
    }
    if (oauth["accesstoken"]) then
      parameters["oauth_token"] = oauth["accesstoken"]
    end
    if (oauth["callback"]) then
      parameters["oauth_callback"] = unescape_uri(oauth["callback"])
    end
    parameters["oauth_signature"] = signature(opts, parameters)
    opts["headers"]["Authorization"] = "OAuth " .. qsencode(parameters, ',', '"')
  end
end
authHeader = function(opts)
  local auth = opts["auth"]
  if opts["auth"] then
    if auth["oauth"] then
      return oauthHeader(opts)
    end
    local cred = encode_base64(auth[0] .. ':' .. auth[1])
    opts.headers["Authorization"] = "Basic " .. cred
  end
end
ngx_request = function(request_uri, opts)
  if opts == nil then
    opts = { }
  end
  local capture_url = opts.capture_url or "/__capture"
  local capture_variable = opts.capture_variable or "url"
  local method = opts.method
  local uri = request_uri
  local req_t = { }
  local new_method = ngx["HTTP_" .. method]
  req_t = {
    args = {
      [capture_variable] = uri
    },
    method = new_method
  }
  local bh = ngx.req.get_headers()
  for k, v in pairs(bh) do
    ngx.req.clear_header(k)
  end
  local h = opts.headers or {
    ["Accept"] = "*/*"
  }
  for k, v in pairs(h) do
    ngx.req.set_header(k, v)
  end
  if opts.body then
    req_t.body = opts.body
  end
  local rsp, err = ngx.location.capture(capture_url, req_t)
  if not rsp then
    ngx.log(ngx.DEBUG, "failed to make request: ", err)
    return {
      statuscode = 0,
      err = err,
      req = opts
    }
  end
  return {
    content = rsp.body,
    statuscode = rsp.status,
    headers = rsp.header,
    req = opts,
    rsp = rsp
  }
end
do
  local _class_0
  local _base_0 = {
    request = function(self, opts)
      if opts == nil then
        opts = { }
      end
      if type(opts) == 'string' then
        opts = {
          url = opts
        }
      end
      if opts.url == nil then
        return {
          statuscode = 0,
          err = "url is required"
        }
      end
      local httpc = http_handle.new()
      local parsed_url = util.url_parse(opts.url)
      opts["parsed_url"] = parsed_url
      opts["headers"] = opts["headers"] or {
        ["Accept"] = "*/*"
      }
      opts["method"] = opts["method"] or "GET"
      opts["method"] = string.upper(opts["method"] .. "")
      opts["headers"]["User-Agent"] = "Mozilla/5.0"
      if opts["data"] then
        opts["body"] = (type(opts["data"]) == "table") and encode_args(opts["data"]) or opts["data"]
        opts["Content-Length"] = strlen(opts["body"] or '')
      end
      local base_uri = url.scheme .. "://" .. url.host .. url.port .. url.path
      opts.base_uri = base_uri
      opts.query = url.query
      authHeader(opts)
      local args = {
        method = opts.method,
        body = opts.body,
        headers = opts.headers,
        ssl_verify = false,
        capture_url = opts.capture_url,
        capture_variable = opts.capture_variable
      }
      if query then
        base_uri = base_uri .. '?' .. query
      end
      if (opts.capture_url or opts.use_capture) then
        return ngx_request(base_uri, args)
      end
      local rsp, err = {
        httpc = request_uri(base_uri, args)
      }
      if not (err) then
        return {
          content = rsp.body,
          statuscode = rsp.status,
          headers = rsp.headers,
          req = opts,
          rsp = rsp
        }
      end
      ngx.log(ngx.DEBUG, "failed to make request: ", err)
      return {
        statuscode = 0,
        err = err,
        req = opts
      }
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function() end,
    __base = _base_0,
    __name = "HttpClient"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  HttpClient = _class_0
end
return {
  HttpClient = HttpClient
}
