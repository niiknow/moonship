
http_handle       = require "resty.http"

local *
request_ngx = (request_uri, opts={}) ->
  capture_url = opts.capture_url or "/__capture"
  capture_variable = opts.capture_variable  or "url"

  method = opts.method
  new_method = ngx["HTTP_" .. method]

  req_t = {
    args: {[capture_variable]: request_uri},
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

  { body: rsp.body, status: "#{rsp.status}", code: rsp.status, headers: rsp.headers, error: err }

-- simulate socket.http
--{
--  method = string,
--  url = string,
--  headers = header-table,
--  body = string,
--  user = string,
--  password = string,
--  stay = string,
--}
--
-- {
--  body = string,
--  headers = header-table,
--  status = string,
--  code = number,
--  error = string
--}
request: (opts) ->
  if type(opts) == 'string' then
    opts = { url: opts, method: 'GET' }

  -- clean args
  options = {
    method: opts.method,
    body: opts.body,
    headers: opts.headers,
    ssl_verify: false,
    capture_url: opts.capture_url,
    capture_variable: opts.capture_variable
  }

  if (opts.capture_url) then
    return ngx_request(opts.url, options)

  rsp, err = httpc:request_uri(opts.url, options)

  { body: rsp.body, status: rsp.reason, code: rsp.status, headers: rsp.headers, error: err }

{
  :request, :request_ngx
}
