config = require "moonship.config"
codecacher = require "moonship.codecacher"
util = require "moonship.util"
sandbox = require "moonship.sandbox"
httpc = require "moonship.http"

local *

loadCode = (url) ->
  res = httpc.request({ url: url, method: "GET", capture_url: "/__githubraw" })

  if res.status == 200
    return res.body

  "nil"

buildRequest = () ->
  if ngx
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
    if base
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

  handleResponse: (rst) =>
    if type(rst) ~= 'table'
      return {body: rst, code: 500, status: "500 unexpected response", headers: {'Content-Type': "text/plain"}}

    rst.code = rst.code or 200
    rst.headers["Content-Type"] = rst.headers["Content-Type"] or "text/plain"
    rst

  engage: (host=(ngx and ngx.var.host), uri=(ngx and ngx.var.uri)) =>
    path = util.sanitizePath(string.format("%s/%s", host, uri))
    rst, err = @codeAdaptor.run(path)
    unless err
      return @handleResponse(rst)

    { error: err, code: 500, status: "500 Engine.engage error" }

{
  :Engine
}
