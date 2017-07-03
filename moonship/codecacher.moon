lfs               = require "lfs"
lru               = require "lru"
httpc             = require "moonship.httpclient"
ngin              = require "moonship.ngin"
sandbox           = require "moonship.sandbox"
util              = require "moonship.util"
plpath            = require "pl.path"

--
-- the strategy of this cache is to:
--1. dynamically load remote file
--2. cache it locally
--3. use local file to trigger cache purge
--4. use ttl (in seconds) to determine how often to check remote file
-- when we have the file, it is recommended to check every hour
-- when we don't have the file, check every x seconds - limit by proxy
class CodeCacher

  new: (localBasePath, ttl, codeHandler, code_cache_size, myUrlHandler) =>
    @codeCache = lru.new(code_cache_size or 10000)

    @urlHandler = codeHandler or myUrlHandler
    @defaultTtl = ttl or 3600 -- default to 1 hours

    -- should not be lower than 2 minutes
    -- user should use cache clearing mechanism
    if (@defaultTtl < 120) then
      @defaultTtl = 120

    @localBasePath = plpath.abspath(localBasePath)

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

  doCheckRemoteFile: (valHolder) =>
    opts = {
      url: valHolder.url
    }

    if (valHolder.fileMod ~= nil) then
      opts["last_modified"] = os.date("%c", valHolder.fileMod)

    os.execute("mkdir -p \"" .. valHolder.localPath .. "\"")

    -- if remote return 200
    rsp, err = @urlHandler(opts)

    if (rsp.status == 200) then
      -- ngx.say(valHolder.localPath)
      -- write file, load data

      with io.open(valHolder.localFullPath, "w")
        \write(rsp.body)
        \close()

      valHolder.fileMod = lfs.attributes valHolder.localFullPath, "modification"
      valHolder.value = sandbox.loadstring rsp.body, nil, ngin.getSandboxEnv()
    elseif (rsp.status == 404) then
      -- on 404 - set nil and delete local file
      valHolder.value = nil
      os.remove(valHolder.localFullPath)

  get: (url) =>
    valHolder = @codeCache\get(url)

    -- initialize valHolder
    if (valHolder == nil) then
      -- strip query string and http/https://
      domainAndPath, query = string.match(url, "([^?#]*)(.*)")
      domainAndPath = string.gsub(string.gsub(domainAndPath, "http://", ""), "https://", "")

      -- expect directory
      fileBasePath = utils.sanitizePath(localBasePath .. "/" .. domainAndPath)

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

    if (valHolder.value == nil or (valHolder.lastCheck < (os.time() - @defaultTtl))) then
      -- load file if it exists
      valHolder.fileMod = lfs.attributes valHolder.localFullPath, "modification"
      if (valHolder.fileMod ~= nil) then

        valHolder.value = sandbox.loadfile valHolder.localFullPath, ngin.getSandboxEnv()

        -- set it back immediately for the next guy
        -- set next ttl
        valHolder.lastCheck = os.time()
        @codeCache\set url, valHolder
      else
        -- delete reference if file no longer exists/purged
        valHolder.value = nil

      @doCheckRemoteFile(valHolder)

    -- remove from cache if not found
    if valHolder.value == nil then
      @codeCache\delete(url)

    valHolder.value

{
  :CodeCacher
}
