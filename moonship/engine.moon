config = require "moonship.config"
codecacher = require "moonship.codecacher"
util = require "moonship.util"
sandbox = require "moonship.sandbox"
httpc = require "moonship.http"

local *

loadngx = (url) ->
  res = httpc.request({ url: url, method: "GET", capture_url: "/__githubraw" })

  if res.status == 200 then
    return res.body

  return "nil"

parseGithubRawLua = (modname) ->
  capturePath = "https://raw.githubusercontent.com/"
  if rawget(_G, __ghrawbase) == nil then
    -- only handle github.com for now
    if string.find(modname, "github.com/") then
      user, repo, branch, pathx, query = string.match(modname, "github%.com/([^/]+)(/[^/]+)/blob(/[^/]+)(/[^?#]*)(.*)")
      path, file = string.match(pathx, "^(.*/)([^/]*)$")
      base = string.format("%s%s%s%s%s", capturePath, user, repo, branch, path)

      -- convert period to folder before return
      base, string.gsub(string.gsub(file, "%.moon$", ""), '%.', "/") .. ".moon", query

  else
    __ghrawbase, string.gsub(string.gsub(modname, "%.moon$", ""), '%.', "/") .. ".moon", ""

getSandboxEnv = () ->
  env = {
    http: httpc,
    require: require_new,
    util: util,
    crypto: crypto,
    request: getRequest(),
    __ghrawbase: __ghrawbase
  }
  sandbox.build_env(_G or _ENV, env, sandbox.whitelist)

getRequest = () ->
  ngx.req.read_body()
  req_wrapper = {
    referer: ngx.var.http_referer or "",
    form: ngx.req.get_post_args(),
    body: ngx.req.get_body_data(),
    query: ngx.req.get_uri_args(),
    querystring: ngx.req.args,
    method: ngx.req.get_method(),
    remote_addr: ngx.var.remote_addr,
    scheme: ngx.var.scheme,
    port: ngx.var.server_port,
    server_addr: ngx.var.server_addr,
    path: ngx.var.uri,
    headers: ngx.req.get_headers()
  }
  req_wrapper

handleResponse = (first, second) ->
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

require_new = (modname) ->
  newEnv = getSandboxEnv()
  if newEnv[modname] then
    return newEnv[modname]
  else
    base, file, query = parseGithubRawLua(modname)
    if base then
      code = loadngx(base .. file .. query)
      -- return code

      -- todo: redo sandbox to cache compiled code somewhere
      newEnv.__ghrawbase = base
      fn, err = sandbox.loadstring(code, nil, newEnv)
      return sandbox.exec(fn)



  nil, "unable to load module [" .. modname .. "]"

class Engine
  new: (options={}) =>
    @options = config.Config\new(options)
    @codeCache = codecacher.CodeCacher\new(@options)

  engage: (host, uri) =>
    path = util.sanitizePath(string.format("%s/%s", host, uri))
    fn = @codeCache\get(path)
    unless fn
      rsp = sandbox.exec(fn)
      return rsp

  engageOpenResty: =>
    @engage ngx.var.host, ngx.var.uri


class EngineOpenResty extends Engine
  new: (options={}) =>
    @options = config.Config\new(options)
    @codeCache = codecacher.CodeCacher\new(@options)

  engage: (host, uri) =>
    path = util.sanitizePath(string.format("%s/%s", ngx.var.host, ngx.var.uri))
    fn = @codeCache\get(path)
    unless fn
      rsp = sandbox.exec(fn)
      return rsp

{
  :Engine,
  :EngineOpenResty
}
