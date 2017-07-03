config = require "moonship.config"
codecacher = require "moonship.codecacher"
util = require "moonship.util"
sandbox = require "moonship.sandbox"
httpc = require "moonship.http"

local *

loadCode = (url) ->
  res = httpc.request({ url: url, method: "GET", capture_url: "/__githubraw" })

  if res.status == 200 then
    return res.body

  "nil"

buildRequest = () ->
  if (ngx) then
    ngx.req.read_body()
    req_wrapper = {
      body: ngx.req.get_body_data(),
      form: ngx.req.get_post_args(),
      headers: ngx.req.get_headers()
      method: ngx.req.get_method(),
      path: ngx.var.uri,
      port: ngx.var.server_port,
      query: ngx.req.get_uri_args(),
      querystring: ngx.req.args,
      remote_addr: ngx.var.remote_addr,
      referer: ngx.var.http_referer or "-",
      scheme: ngx.var.scheme,
      server_addr: ngx.var.server_addr,
      user_agent: ""
    }
    req_wrapper.user_agent = req_wrapper.headers["User-Agent"]
    return req_wrapper

  {}

require_new = (modname) ->
  unless _G[modname]
    base, file, query = util.resolveGithubRaw(modname)
    if base then
      code = @loadCode("#{base}#{file}#{query}")
      _G["__ghrawbase"] = base
      fn, err = sandbox.loadstring(code, nil, _G)
      unless fn
        return nil, "error loading '#{modname}' with message: #{err}"

      rst, err = sandbox.exec(fn)
      unless rst
        return nil, "error executing '#{modname}' with message: #{err}"

      _G[modname] = rst

  _G[modname]

getSandboxEnv: () ->
  env = {
    http: httpc,
    require: require_new,
    util: util,
    crypto: crypto,
    request: buildRequest(),
    __ghrawbase: __ghrawbase
  }
  sandbox.build_env(_G, env, sandbox.whitelist)

-- response with
-- :body, :code, :headers, :status, :error
class Engine
  new: (options={}) =>
    @options = config.Config\new(options)
    @codeCache = codecacher.CodeCacher\new(@options)

  handleResponse: (first, second) =>
    statusCode = 200
    msg = ""
    contentType = "text/plain"
    opts = {}
    req_method = string.lower(ngx.req.get_method())

    if type(first) == 'number' then
      statusCode = first

      if type(second) == 'string' then
        msg = second

    elseif type(first) == 'string' then
      msg = first
    elseif type(first) == 'table' then

      -- attempt to execute the method that is required
      func = first[req_method]
      if (type(func) == 'function') then
        -- execute the function in sandbox
        env = getSandboxEnv()
        setfenv(func, env)

        rsp, err = func()
        second = rsp.headers or {}
        msg = rsp.content
        statusCode = rsp.statuscode or statusCode
      else
        statusCode = 404


    if type(second) == 'table' then
      for k, v in pairs(second) do
        ngx.header[k] = v
        if ('content-type' == string.lower(k)) then
          contentType = nil

    if (contentType ~= nil) then
      ngx.header['Content-Type'] = contentType

    ngx.status = statusCode
    ngx.say(msg)
    ngx.exit(statusCode)

  engage: (host=(ngx and ngx.var.host), uri=(ngx and ngx.var.uri)) =>
    path = util.sanitizePath(string.format("%s/%s", host, uri))
    rst, err = @codeAdaptor.run(path)
    unless err
      return {body: rst.body, headers: rst.headers, status: rst.status, code: rst.code or 200 }

    {error: err, code: 500, status: "500 error running remote code" }

{
  :Engine
}
