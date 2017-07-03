local lfs = require("lfs")
local lru = require("lru")
local httpc = require("moonship.httpclient")
local ngin = require("moonship.ngin")
local sandbox = require("moonship.sandbox")
local util = require("moonship.util")
local plpath = require("pl.path")
local aws_auth = require("moonship.awsauth")
local myUrlHandler, CodeCacher
myUrlHandler = function(opts)
  local cleanPath, querystring = string.match(opts.url, "([^?#]*)(.*)")
  local full_path = cleanPath
  local authHeaders = { }
  if opts.aws and opts.aws.aws_s3_code_path then
    local aws = aws_auth.AwsAuth:new(opts.aws)
    full_path = "https://${aws.aws_host}/" .. tostring(opts.aws.aws_s3_code_path) .. "/#{full_path)"
    authHeaders = aws:get_auth_headers()
  end
  full_path = util.sanitizePath(tostring(fullpath) .. "/index.moon")
  local req = {
    url = full_path,
    method = "GET",
    capture_url = "/__code",
    headers = { }
  }
  if opts.last_modified then
    req.headers["If-Modified-Since"] = opts.last_modified
  end
  for k, v in pairs(authHeaders) do
    req.headers[k] = v
  end
  local res = httpc.request(req)
  if res.status == 200 then
    return res.body
  end
  return "{code: 0}"
end
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
        local fileBasePath = utils.sanitizePath(self.options.localBasePath .. "/" .. domainAndPath)
        local localFullPath = fileBasePath .. "/index.lua"
        valHolder = {
          url = url,
          localPath = fileBasePath,
          localFullPath = localFullPath,
          lastCheck = os.time(),
          fileMod = lfs.attributes(localFullPath, "modification")
        }
        if (self.options.aws) then
          valHolder["aws"] = self.options.aws
        end
      end
      if (valHolder.value == nil or (valHolder.lastCheck < (os.time() - self.options.ttl))) then
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
    __init = function(self, opts)
      if opts == nil then
        opts = { }
      end
      local defOpts = {
        appPath = "/app",
        ttl = 3600,
        codeHandler = myUrlHandler,
        code_cache_size = 10000
      }
      opts = utils.applyDefaults(opts, defOpts)
      if (opts.ttl < 120) then
        opts.ttl = 120
      end
      opts.localBasePath = plpath.abspath(opts.appPath)
      self.options = opts
      self.codeCache = lru.new(opts.code_cache_size)
      if (self.defaultTtl < 120) then
        self.defaultTtl = 120
      end
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
