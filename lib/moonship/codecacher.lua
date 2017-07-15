local aws_auth = require("moonship.awsauth")
local httpc = require("moonship.http")
local sandbox = require("moonship.sandbox")
local util = require("moonship.util")
local lfs = require("lfs")
local lru = require("lru")
local plpath = require("path")
local log = require("moonship.log")
local fs = require("path.fs")
local mkdirp, myUrlHandler, CodeCacher
mkdirp = function(p)
  return fs.makedirs(p)
end
myUrlHandler = function(opts)
  local cleanPath, querystring = string.match(opts.url, "([^?#]*)(.*)")
  local full_path = util.path_sanitize(cleanPath)
  local authHeaders = { }
  full_path = util.path_sanitize(tostring(full_path) .. "/index.moon")
  if opts.aws and opts.aws.aws_s3_code_path then
    opts.aws.request_path = "/" .. tostring(opts.aws.aws_s3_code_path) .. "/" .. tostring(full_path)
    local aws = aws_auth(opts.aws)
    full_path = "https://" .. tostring(aws.options.aws_host) .. tostring(opts.aws.request_path)
    authHeaders = aws:get_auth_headers()
  else
    full_path = tostring(opts.remote_path) .. "/" .. tostring(full_path)
  end
  log.debug("code load: " .. tostring(full_path))
  local req = {
    url = full_path,
    method = "GET",
    capture_url = "/__libprivate",
    headers = { }
  }
  if opts.last_modified then
    req.headers["If-Modified-Since"] = opts.last_modified
  end
  for k, v in pairs(authHeaders) do
    req.headers[k] = v
  end
  local res, err = httpc.request(req)
  if not (err) then
    return res
  end
  log.debug("code load error: " .. tostring(err))
  return {
    code = 0,
    body = err
  }
end
do
  local _class_0
  local _base_0 = {
    doCheckRemoteFile = function(self, valHolder, aws)
      local opts = {
        url = valHolder.url,
        remote_path = self.options.remote_path
      }
      if (valHolder.fileMod ~= nil) then
        opts["last_modified"] = os.date("%c", valHolder.fileMod)
      end
      if not (opts.remote_path) then
        opts.aws = aws
      end
      local rsp, err = self.options.codeHandler(opts)
      if (rsp.code == 200) then
        if (rsp.body) then
          local lua_src = sandbox.compile_moon(rsp.body)
          if (lua_src) then
            mkdirp(valHolder.localPath)
            local file = io.open(valHolder.localFullPath, "w")
            if file then
              file:write(lua_src)
              file:close()
              valHolder.fileMod = lfs.attributes(valHolder.localFullPath, "modification")
              valHolder.value = sandbox.loadstring_safe(lua_src, valHolder.localFullPath, self.options.sandbox_env)
            end
          end
        end
      elseif (rsp.code == 404) then
        valHolder.value = nil
        return os.remove(valHolder.localFullPath)
      end
    end,
    get = function(self, aws)
      local req = self.options.requestbuilder:build()
      self.options.sandbox_env.request = req
      local url = util.path_sanitize(tostring(req.host) .. "/" .. tostring(req.path))
      local valHolder = self.codeCache:get()
      if not (valHolder) then
        local domainAndPath, query = string.match(url, "([^?#]*)(.*)")
        domainAndPath = string.gsub(string.gsub(domainAndPath, "http://", ""), "https://", "")
        local fileBasePath = util.path_sanitize(self.options.localBasePath .. "/" .. domainAndPath)
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
        if valHolder.fileMod then
          log.debug(tostring(valHolder.fileMod))
          valHolder.value = sandbox.loadfile_safe(valHolder.localFullPath, self.options.sandbox_env)
          valHolder.lastCheck = os.time()
          self.codeCache:set(url, valHolder)
        else
          valHolder.value = nil
        end
        self:doCheckRemoteFile(valHolder, aws)
      end
      if valHolder.value == nil then
        self.codeCache:delete(url)
      end
      if (type(valHolder.value) == "function") then
        return sandbox.exec(valHolder.value)
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
        app_path = "/app",
        ttl = 3600,
        codeHandler = myUrlHandler,
        code_cache_size = 10000
      }
      util.applyDefaults(opts, defOpts)
      if (opts.ttl < 120) then
        opts.ttl = 120
      end
      opts.localBasePath = plpath.abs(opts.app_path)
      opts["sandbox_env"] = sandbox.build_env(_G, opts.plugins, sandbox.whitelist)
      self.codeCache = lru.new(opts.code_cache_size)
      self.options = opts
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
  CodeCacher = CodeCacher,
  myUrlHandler = myUrlHandler
}
