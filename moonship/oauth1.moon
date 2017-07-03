util              = require "moonship.util"

escape_uri        = ngx and ngx.escape_uri or util.url_escape
unescape_uri      = ngx and ngx.unescape_uri or util.url_unescape
encode_base64     = ngx and ngx.encode_base64 or crypto.base64_encode
string_split      = util.split
digest_hmac_sha1  = ngx and ngx.hmac_sha1 or (key, str) -> crypto.hmac(key, str, crypto.sha1).digest()
digest_md5        = ngx and ngx.md5 or (str) -> crypto.md5(str).hex()
qs_encode         = util.query_string_encode
url_parse         = util.url_parse
url_build         = util.url_build

local *

normalizeParameters: (parameters, body, query) ->
  items = {qs_encode(parameters, "&")}
  if body then
    string_split(body, "&", items)

  if query then
    string_split(query, "&", items)

  table.sort(items)
  table.concat(items, "&")

calculateBaseString: (body, method, query, base_uri, parameters) ->
  parms = normalizeParameters(parameters, body, query)
  escape_uri(method) .. "&" .. escape_uri(base_uri) .. "&" .. escape_uri(parms)

secret = (oauth) ->
  unescape_uri(oauth["consumersecret"]) .. "&" .. unescape_uri(oauth["tokensecret"] or "")

sign = (body, method, query, base_uri, parameters) ->
  strToSign = calculateBaseString(body, method, query, base_uri, parameters)
  signedString = digest_hmac_sha1(secret(opts["oauth"]), strToSign)
  encode_base64(signedString)

create_signature = (opts, oauth) ->
  -- parse url for query string
  parsed_url = url_parse(opts.url)
  query = parsed_url.query

  -- uri without querystring
  parsed_url.query = nil
  parsed_url.fragment = nil
  base_uri = url_build(parsed_url)

  timestamp = os.time()
  parameters = {
    oauth_consumer_key: oauth["consumerkey"],
    oauth_token: oauth["accesstoken"],
    oauth_signature_method: "HMAC-SHA1",
    oauth_timestamp: timestamp,
    oauth_nonce: digest_md5(timestamp .. ""),
    oauth_version: oauth["version"] or "1.0"
  }

  if (oauth["accesstoken"]) then
    parameters["oauth_token"] = oauth["accesstoken"]

  if (oauth["callback"]) then
    parameters["oauth_callback"] = unescape_uri(oauth["callback"])

  parameters["oauth_signature"] = sign(opts["body"], opts["method"] or 'GET', query, base_uri, parameters)

  "OAuth " .. qs_encode(parameters, ",", "\"")

{
  :create_signature
}
