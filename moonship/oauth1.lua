local util = require("moonship.util")
local escape_uri = ngx and ngx.escape_uri or util.url_escape
local unescape_uri = ngx and ngx.unescape_uri or util.url_unescape
local encode_base64 = ngx and ngx.encode_base64 or crypto.base64_encode
local string_split = util.split
local digest_hmac_sha1 = ngx and ngx.hmac_sha1 or function(key, str)
  return crypto.hmac(key, str, crypto.sha1).digest()
end
local digest_md5 = ngx and ngx.md5 or function(str)
  return crypto.md5(str).hex()
end
local qs_encode = util.query_string_encode
local url_parse = util.url_parse
local url_build = util.url_build
local secret, sign, create_signature
local _ = {
  normalizeParameters = function(parameters, body, query)
    local items = {
      qs_encode(parameters, "&")
    }
    if body then
      string_split(body, "&", items)
    end
    if query then
      string_split(query, "&", items)
    end
    table.sort(items)
    return table.concat(items, "&")
  end
}
_ = {
  calculateBaseString = function(body, method, query, base_uri, parameters)
    local parms = normalizeParameters(parameters, body, query)
    return escape_uri(method) .. "&" .. escape_uri(base_uri) .. "&" .. escape_uri(parms)
  end
}
secret = function(oauth)
  return unescape_uri(oauth["consumersecret"]) .. "&" .. unescape_uri(oauth["tokensecret"] or "")
end
sign = function(body, method, query, base_uri, parameters)
  local strToSign = calculateBaseString(body, method, query, base_uri, parameters)
  local signedString = digest_hmac_sha1(secret(opts["oauth"]), strToSign)
  return encode_base64(signedString)
end
create_signature = function(opts, oauth)
  local parsed_url = url_parse(opts.url)
  local query = parsed_url.query
  parsed_url.query = nil
  parsed_url.fragment = nil
  local base_uri = url_build(parsed_url)
  local timestamp = os.time()
  local parameters = {
    oauth_consumer_key = oauth["consumerkey"],
    oauth_token = oauth["accesstoken"],
    oauth_signature_method = "HMAC-SHA1",
    oauth_timestamp = timestamp,
    oauth_nonce = digest_md5(timestamp .. ""),
    oauth_version = oauth["version"] or "1.0"
  }
  if (oauth["accesstoken"]) then
    parameters["oauth_token"] = oauth["accesstoken"]
  end
  if (oauth["callback"]) then
    parameters["oauth_callback"] = unescape_uri(oauth["callback"])
  end
  parameters["oauth_signature"] = sign(opts["body"], opts["method"] or 'GET', query, base_uri, parameters)
  return "OAuth " .. qs_encode(parameters, ",", "\"")
end
return {
  create_signature = create_signature
}
