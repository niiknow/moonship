import sort, concat from table
util              = require "moonship.util"
crypto            = require "moonship.crypto"

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

normalizeParameters = (parameters, body, query) ->
  items = { qs_encode(parameters, "&") }
  string_split(body, "&", items) if body
  string_split(query, "&", items) if query

  sort(items)
  concat(items, "&")

calculateBaseString = (body, method, query, base_uri, parameters) ->
  parms = normalizeParameters(parameters, body, query)
  escape_uri(method) .. "&" .. escape_uri(base_uri) .. "&" .. escape_uri(parms)

secret = (oauth) ->
  unescape_uri(oauth["consumersecret"]) .. "&" .. unescape_uri(oauth["tokensecret"] or "")

sign = (body, method, query, base_uri, oauth, parameters) ->
  strToSign = calculateBaseString(body, method, query, base_uri, parameters)
  signedString = digest_hmac_sha1(secret(oauth), strToSign)
  encode_base64(signedString)

create_signature = (opts, oauth) ->
  -- parse url for query string
  parts = url_parse(opts.url)
  query = parts.query
  base_uri = url_build(parts, false)

  -- allow for unit testing by passing in timestamp
  timestamp = oauth['timestamp'] or os.time()
  parameters = {
    oauth_consumer_key: oauth["consumerkey"],
    oauth_token: oauth["accesstoken"],
    oauth_signature_method: "HMAC-SHA1",
    oauth_timestamp: timestamp,
    oauth_nonce: digest_md5(timestamp .. ""),
    oauth_version: oauth["version"] or "1.0"
  }

  parameters["oauth_token"] = oauth["accesstoken"] if oauth["accesstoken"]
  parameters["oauth_callback"] = unescape_uri(oauth["callback"]) if oauth["callback"]
  parameters["oauth_signature"] = sign(opts["body"], opts["method"] or 'GET', query, base_uri, oauth, parameters)

  "OAuth " .. qs_encode(parameters, ",", "\"")

{ :create_signature }
