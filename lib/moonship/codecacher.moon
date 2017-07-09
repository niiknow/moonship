
aws_auth         = require "moonship.awsauth"
httpc            = require "moonship.http"
sandbox          = require "moonship.sandbox"
util             = require "moonship.util"

lfs              = require "lfs"
lru              = require "lru"
plpath           = require "path"
log              = require "moonship.log"
fs               = require "path.fs"
requestbuilder   = require "moonship.requestbuilder"

local *

mkdirp = (p) ->
  fs.makedirs p

myUrlHandler = (opts) ->
  -- ngx.log(ngx.ERR, "mydebug: " .. secret_key)
  cleanPath, querystring  = string.match(opts.url, "([^?#]*)(.*)")
  full_path               = util.path_sanitize(cleanPath)
  authHeaders             = {}
  full_path               = util.path_sanitize("#{full_path}/index.moon")

  if opts.aws and opts.aws.aws_s3_code_path
    -- process s3 stuff
    opts.aws.request_path = "/#{opts.aws.aws_s3_code_path}/#{full_path}"
    aws = aws_auth(opts.aws)
    full_path = "https://#{aws.options.aws_host}#{opts.aws.request_path}"
    authHeaders = aws\get_auth_headers()
  else
    full_path = "#{opts.remote_path}/#{full_path}"

  log.debug "code load: #{full_path}"

  req = { url: full_path, method: "GET", capture_url: "/__libprivate", headers: {} }
  req.headers["If-Modified-Since"] = opts.last_modified if opts.last_modified

  for k, v in pairs(authHeaders) do
    req.headers[k] = v

  res, err = httpc.request(req)
  return res unless err

  log.debug "code load error: #{err}"

  { code: 0, body: err }

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
    defOpts = {app_path: "/app", ttl: 3600, codeHandler: myUrlHandler, code_cache_size: 10000, :requestbuilder}
    util.applyDefaults(opts, defOpts)

    -- should not be lower than 2 minutes
    -- user should use cache clearing mechanism
    opts.ttl = 120 if (opts.ttl < 120)

    opts.localBasePath = plpath.abs(opts.app_path)
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

  doCheckRemoteFile: (valHolder, aws) =>
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
          mkdirp(valHolder.localPath)
          file = io.open(valHolder.localFullPath, "w")
          if file
            file\write(lua_src)
            file\close()

            valHolder.fileMod = lfs.attributes valHolder.localFullPath, "modification"
            valHolder.value = sandbox.loadstring_safe lua_src, valHolder.localFullPath, @options.sandbox_env

    elseif (rsp.code == 404)
      -- on 404 - set nil and delete local file
      valHolder.value = nil
      os.remove(valHolder.localFullPath)

  get: (aws) =>
    req = @options.requestbuilder.build()
    @options.sandbox_env.request = req
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
        valHolder.value = sandbox.loadfile_safe valHolder.localFullPath, @options.sandbox_env

        -- set it back immediately for the next guy
        -- set next ttl
        valHolder.lastCheck = os.time()
        @codeCache\set url, valHolder
      else
        -- delete reference if file no longer exists/purged
        valHolder.value = nil

      @doCheckRemoteFile(valHolder, aws)

    -- remove from cache if not found
    @codeCache\delete(url) if valHolder.value == nil
    return sandbox.exec(valHolder.value) if (type(valHolder.value) == "function")

    valHolder.value

{ :CodeCacher, :myUrlHandler }
