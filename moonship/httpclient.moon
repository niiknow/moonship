-- derived from https://github.com/pintsized/lua-resty-http
-- add ability to use capture and authenticate with oauth1.0

http_handle       = require "moonship.http"
util              = require "moonship.util"
ltn12             = require "ltn12"

escape_uri        = ngx and ngx.escape_uri or util.url_escape
unescape_uri      = ngx and ngx.unescape_uri or util.url_unescape
encode_args       = ngx and ngx.encode_args or util.query_string_encode
encode_base64     = ngx and ngx.encode_base64 or crypto.base64_encode
string_split      = util.split
digest_hmac_sha1  = ngx and ngx.hmac_sha1 or (key, str) -> crypto.hmac(key, str, crypto.sha1).digest()
digest_md5        = ngx and ngx.md5 or (str) -> crypto.md5(str).hex()

local *

normalizeParameters: (parameters, body, query) ->
  items = {qsencode(parameters, '&')}
  if body then
    string_split(body, '&', items)

  if query then
    string_split(query, '&', items)

  table.sort(items)
  table.concat(items, '&')

calculateBaseString: (opts, parameters) ->
  body = opts["body"]
  url = opts["parsed_url"]
  method = opts["method"]
  parms = normalizeParameters(parameters, body, url.query)
  escape_uri(method) .. "&" .. escape_uri(opts["base_uri"]) .. "&" .. escape_uri(parms)

secret = (auth) ->
  oauth = auth["oauth"]
  unescape_uri(oauth["consumersecret"]) .. '&' .. unescape_uri(oauth["tokensecret"] or '')

signature = (opts, parameters) ->
  strToSign = calculateBaseString(opts, parameters)
  opts.strToSign = strToSign
  signedString = digest_hmac_sha1(secret(opts["auth"]), strToSign)
  opts.signature = resultparms
  encode_base64(signedString)

oauthHeader = (opts) ->
  oauth = opts["auth"]["oauth"]
  if oauth then
    timestamp = os.time()
    parameters = {
      oauth_consumer_key: oauth["consumerkey"],
      oauth_token: oauth["accesstoken"],
      oauth_signature_method: "HMAC-SHA1",
      oauth_timestamp: timestamp,
      oauth_nonce: digest_md5(timestamp .. ''),
      oauth_version: oauth["version"] or '1.0'
    }

    if (oauth["accesstoken"]) then
      parameters["oauth_token"] = oauth["accesstoken"]


    if (oauth["callback"]) then
      parameters["oauth_callback"] = unescape_uri(oauth["callback"])


    parameters["oauth_signature"] = signature(opts, parameters)
    opts["headers"]["Authorization"] =  "OAuth " .. qsencode(parameters, ',', '"')

authHeader = (opts) ->
  auth = opts["auth"]
  if opts["auth"] then
    if auth["oauth"] then
      return oauthHeader(opts)

    cred = encode_base64(auth[0] .. ':' .. auth[1])
    opts.headers["Authorization"] = "Basic " .. cred

ngx_request = (request_uri, opts={}) ->
  capture_url = opts.capture_url or "/__capture"
  capture_variable = opts.capture_variable  or "url"

  method = opts.method
  uri = request_uri
  req_t = {}
  new_method = ngx["HTTP_" .. method]

  req_t = {
    args: {[capture_variable]: uri},
    method: new_method
  }

  -- clear all browser headers
  bh = ngx.req.get_headers()
  for k, v in pairs(bh) do
    ngx.req.clear_header(k)

  h = opts.headers or {["Accept"]: "*/*"}
  for k,v in pairs(h) do
    ngx.req.set_header(k, v)

  if opts.body then req_t.body = opts.body

  rsp, err = ngx.location.capture(capture_url, req_t)

  if not rsp then
    ngx.log(ngx.DEBUG, "failed to make request: ", err)
    return { statuscode: 0, err: err, req: opts }


  { content: rsp.body, statuscode: rsp.status, headers: rsp.header, req: opts, rsp: rsp }

class HttpClient
  request: (opts={}) =>
    if type(opts) == 'string' then
      opts = { url: opts }

    if opts.url == nil then
      return { statuscode: 0, err: "url is required" }

    httpc = http_handle.new()
    parsed_url = util.url_parse opts.url

    opts["parsed_url"] = parsed_url
    opts["headers"] = opts["headers"] or {["Accept"]: "*/*"}
    opts["method"] = opts["method"] or "GET"
    opts["method"] = string.upper(opts["method"] .. "")
    opts["headers"]["User-Agent"] = "Mozilla/5.0"

    if opts["data"] then
      opts["body"] = (type(opts["data"]) == "table") and encode_args(opts["data"]) or opts["data"]
      opts["Content-Length"] = strlen(opts["body"] or '')

    base_uri = url.scheme .. "://" .. url.host .. url.port .. url.path
    opts.base_uri = base_uri
    opts.query = url.query

    authHeader(opts)
    args = {
      method: opts.method,
      body: opts.body,
      headers: opts.headers,
      ssl_verify: false,
      capture_url: opts.capture_url,
      capture_variable: opts.capture_variable
    }

    -- lua-resty-http issue, we have to reappend query to url
    if query then
      base_uri = base_uri .. '?' .. query


    if (opts.capture_url or opts.use_capture) then
      return ngx_request(base_uri, args)


    rsp, err = httpc:request_uri(base_uri, args)

    unless err
      return { content: rsp.body, statuscode: rsp.status, headers: rsp.headers, req: opts, rsp: rsp }

    ngx.log(ngx.DEBUG, "failed to make request: ", err)
    { statuscode: 0, err: err, req: opts }
{
  :HttpClient
}
