
aws_auth      = require "moonship.awsauth"
httpc         = require "moonship.http"
sandbox       = require "moonship.sandbox"
util          = require "moonship.util"

lfs           = require "lfs"
lru           = require "lru"
plpath        = require "pl.path"
log           = require "moonship.log"

local *
loadCode = (url) ->
  req = { url: url, method: "GET", capture_url: "/__ghraw", headers: {} }
  res, err = httpc.request(req)

  return res unless err

  { code: 0, body: err }

myUrlHandler = (opts) ->
  -- ngx.log(ngx.ERR, "mydebug: " .. secret_key)
  cleanPath, querystring  = string.match(opts.url, "([^?#]*)(.*)")
  full_path               = util.path_sanitize(cleanPath)
  authHeaders             = {}
  full_path               = util.path_sanitize("#{full_path}/index.moon")

  if opts.aws and opts.aws.aws_s3_code_path
    -- process s3 stuff
    opts.aws.request_path = "/#{opts.aws.aws_s3_code_path}/#{full_path}"
    aws = aws_auth.AwsAuth(opts.aws)
    full_path = "https://#{aws.options.aws_host}#{opts.aws.request_path}"
    authHeaders = aws\get_auth_headers()
  else
    full_path = "#{opts.remote_path}/#{full_path}"

  log.debug "code load: #{full_path}"

  req = { url: full_path, method: "GET", capture_url: "/__code", headers: {} }
  req.headers["If-Modified-Since"] = opts.last_modified if opts.last_modified

  for k, v in pairs(authHeaders) do
    req.headers[k] = v

  res, err = httpc.request(req)
  return res unless err

  log.debug "code load error: #{err}"

  { code: 0, body: err }


buildRequest = () ->
  if ngx
    ngx.req.read_body()
    req_wrapper = {
      body: ngx.req.get_body_data(),
      form: ngx.req.get_post_args(),
      headers: ngx.req.get_headers(),
      host: ngx.var.host,
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


getSandboxEnv = (req) ->
  env = {
    http: httpc,
    require: require_new,
    util: util,
    crypto: crypto,
    request: req or buildRequest(),
    __ghrawbase: __ghrawbase
  }
  sandbox.build_env(_G, env, sandbox.whitelist)


require_new = (modname) ->
  unless _G[modname]
    base, file, query = util.resolveGithubRaw(modname)
    if base
      loadPath = "#{base}#{file}#{query}"
      rsp = loadCode(loadPath)
      if (rsp.code == 200)
        lua_src, err = sandbox.compile_moon rsp.body

        return nil, "error compiling '#{modname}' with message: #{err}" unless lua_src

        fn, err = sandbox.loadstring_safe lua_src, loadPath, getSandboxEnv()

        _G["__ghrawbase"] = base
        return nil, "error loading '#{modname}' with message: #{err}" unless fn

        rst, err = sandbox.exec(fn)
        return nil, "error executing '#{modname}' with message: #{err}" unless rst

        _G[modname] = rst

  _G[modname]


--
-- the strategy of this cache is to:
--1. dynamically load remote file
--2. cache it locally
--3. use local file to trigger cache purge
--4. use ttl (in seconds) to determine how often to check remote file
-- when we have the file, it is recommended to check every hour
-- when we don't have the file, check every x seconds - limit by proxy
class CodeCacher

  new: (opts={}) =>
    defOpts = {app_path: "/app", ttl: 3600, codeHandler: myUrlHandler, code_cache_size: 10000}
    util.applyDefaults(opts, defOpts)

    -- should not be lower than 2 minutes
    -- user should use cache clearing mechanism
    opts.ttl = 120 if (opts.ttl < 120)

    opts.localBasePath = plpath.abspath(opts.app_path)
    @codeCache = lru.new(opts.code_cache_size)
    @options = opts

--
--if value holder is nil, initialize value holder
--if value is nil or ttl has expired
-- load File if it exists
  -- set cache for next guy
  -- set fileModification DateTime
-- doCheckRemoteFile()
  -- if remote return 200
    -- write file, load data
  -- on 404 - delete local file, set nil
  -- on other error - do nothing
-- remove from cache if not found
-- return result function

--NOTE: urlHandler should use capture to simulate debounce

  doCheckRemoteFile: (valHolder, req, aws) =>
    opts = {
      url: valHolder.url,
      remote_path: @options.remote_path
    }


    opts["last_modified"] = os.date("%c", valHolder.fileMod) if (valHolder.fileMod ~= nil)

    -- copy over aws options
    unless opts.remote_path
      opts.aws = aws

    -- if remote return 200
    rsp, err = @options.codeHandler(opts)


    if (rsp.code == 200)
      -- ngx.say(valHolder.localPath)
      -- write file, load data
      if (rsp.body)
        lua_src = sandbox.compile_moon rsp.body
        if (lua_src)
          os.execute("mkdir -p \"" .. valHolder.localPath .. "\"")
          with io.open(valHolder.localFullPath, "w")
            \write(lua_src)
            \close()

          valHolder.fileMod = lfs.attributes valHolder.localFullPath, "modification"
          valHolder.value = sandbox.loadstring_safe lua_src, valHolder.localFullPath, getSandboxEnv(req)

    elseif (rsp.code == 404)
      -- on 404 - set nil and delete local file
      valHolder.value = nil
      os.remove(valHolder.localFullPath)

  get: (req=buildRequest(), aws) =>
    url = util.path_sanitize("#{req.host}/#{req.path}")
    valHolder = @codeCache\get()

    -- initialize valHolder
    unless valHolder
      -- strip query string and http/https://
      domainAndPath, query = string.match(url, "([^?#]*)(.*)")
      domainAndPath = string.gsub(string.gsub(domainAndPath, "http://", ""), "https://", "")

      -- expect directory
      fileBasePath = util.path_sanitize(@options.localBasePath .. "/" .. domainAndPath)

      -- must store locally as index.lua
      -- this way, a path can contain other paths
      localFullPath = fileBasePath .. "/index.lua"

      valHolder = {
        url: url,
        localPath: fileBasePath,
        localFullPath: localFullPath,
        lastCheck: os.time(),
        fileMod: lfs.attributes localFullPath, "modification"
      }

      -- use aws s3 if available
      valHolder["aws"] = @options.aws if (@options.aws)

    if (valHolder.value == nil or (valHolder.lastCheck < (os.time() - @options.ttl)))
      -- load file if it exists
      valHolder.fileMod = lfs.attributes valHolder.localFullPath, "modification"
      if valHolder.fileMod
        log.debug tostring(valHolder.fileMod)
        valHolder.value = sandbox.loadfile_safe valHolder.localFullPath, getSandboxEnv(req)

        -- set it back immediately for the next guy
        -- set next ttl
        valHolder.lastCheck = os.time()
        @codeCache\set url, valHolder
      else
        -- delete reference if file no longer exists/purged
        valHolder.value = nil

      @doCheckRemoteFile(valHolder, req, aws)

    -- remove from cache if not found
    @codeCache\delete(url) if valHolder.value == nil
    return sandbox.exec(valHolder.value) if (type(valHolder.value) == "function")

    valHolder.value

{ :CodeCacher, :myUrlHandler, :require_new }
