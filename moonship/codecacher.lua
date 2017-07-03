local lfs = require("lfs")
local lru = require("lru")
local httpc = require("moonship.httpclient")
local ngin = require("moonship.ngin")
local sandbox = require("moonship.sandbox")
local util = require("moonship.util")
local plpath = require("pl.path")
local CodeCacher
do
  local _class_0
  local _base_0 = {
    doCheckRemoteFile = function(self, valHolder)
      local opts = {
        url = valHolder.url
      }
      if (valHolder.fileMod ~= nil) then
        opts["last_modified"] = os.date("%c", valHolder.fileMod)
      end
      os.execute("mkdir -p \"" .. valHolder.localPath .. "\"")
      local rsp, err = self:urlHandler(opts)
      if (rsp.status == 200) then
        do
          local _with_0 = io.open(valHolder.localFullPath, "w")
          _with_0:write(rsp.body)
          _with_0:close()
        end
        valHolder.fileMod = lfs.attributes(valHolder.localFullPath, "modification")
        valHolder.value = sandbox.loadstring(rsp.body, nil, ngin.getSandboxEnv())
      elseif (rsp.status == 404) then
        valHolder.value = nil
        return os.remove(valHolder.localFullPath)
      end
    end,
    get = function(self, url)
      local valHolder = self.codeCache:get(url)
      if (valHolder == nil) then
        local domainAndPath, query = string.match(url, "([^?#]*)(.*)")
        domainAndPath = string.gsub(string.gsub(domainAndPath, "http://", ""), "https://", "")
        local fileBasePath = utils.sanitizePath(localBasePath .. "/" .. domainAndPath)
        local localFullPath = fileBasePath .. "/index.lua"
        valHolder = {
          url = url,
          localPath = fileBasePath,
          localFullPath = localFullPath,
          lastCheck = os.time(),
          fileMod = lfs.attributes(localFullPath, "modification")
        }
      end
      if (valHolder.value == nil or (valHolder.lastCheck < (os.time() - self.defaultTtl))) then
        valHolder.fileMod = lfs.attributes(valHolder.localFullPath, "modification")
        if (valHolder.fileMod ~= nil) then
          valHolder.value = sandbox.loadfile(valHolder.localFullPath, ngin.getSandboxEnv())
          valHolder.lastCheck = os.time()
          self.codeCache:set(url, valHolder)
        else
          valHolder.value = nil
        end
        self:doCheckRemoteFile(valHolder)
      end
      if valHolder.value == nil then
        self.codeCache:delete(url)
      end
      return valHolder.value
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self, localBasePath, ttl, codeHandler, code_cache_size, myUrlHandler)
      self.codeCache = lru.new(code_cache_size or 10000)
      self.urlHandler = codeHandler or myUrlHandler
      self.defaultTtl = ttl or 3600
      if (self.defaultTtl < 120) then
        self.defaultTtl = 120
      end
      self.localBasePath = plpath.abspath(localBasePath)
    end,
    __base = _base_0,
    __name = "CodeCacher"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  CodeCacher = _class_0
end
return {
  CodeCacher = CodeCacher
}
