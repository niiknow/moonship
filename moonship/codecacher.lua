local lfs = require("lfs")
local lru = require("lru")
local httpc = require("moonship.http")
local sandbox = require("moonship.sandbox")
local util = require("moonship.util")
local plpath = require("pl.path")
local aws_auth = require("moonship.awsauth")
local myUrlHandler, buildRequest, require_new, getSandboxEnv, CodeCacher
myUrlHandler = function(opts)
  local cleanPath, querystring = string.match(opts.url, "([^?#]*)(.*)")
  local full_path = util.path_sanitize(cleanPath)
  local authHeaders = { }
  if opts.aws and opts.aws.aws_s3_code_path then
    local aws = aws_auth.AwsAuth(opts.aws)
    full_path = "https://" .. tostring(aws.aws_host) .. "/" .. tostring(opts.aws.aws_s3_code_path) .. "/" .. tostring(full_path)
    authHeaders = aws:get_auth_headers()
  else
    full_path = tostring(opts.remote_path) .. "/" .. tostring(full_path)
  end
  full_path = tostring(full_path) .. "/index.moon"
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
  local res, err = httpc.request(req)
  if not (err) then
    return res
  end
  return {
    code = 0,
    body = err
  }
end
buildRequest = function()
  if ngx then
    ngx.req.read_body()
    local req_wrapper = {
      body = ngx.req.get_body_data(),
      form = ngx.req.get_post_args(),
      headers = ngx.req.get_headers(),
      host = ngx.var.host,
      method = ngx.req.get_method(),
      path = ngx.var.uri,
      port = ngx.var.server_port,
      query = ngx.req.get_uri_args(),
      querystring = ngx.req.args,
      remote_addr = ngx.var.remote_addr,
      referer = ngx.var.http_referer or "-",
      scheme = ngx.var.scheme,
      server_addr = ngx.var.server_addr,
      user_agent = ""
    }
    req_wrapper.user_agent = req_wrapper.headers["User-Agent"]
    return req_wrapper
  end
  return { }
end
require_new = function(modname)
  if not (_G[modname]) then
    local base, file, query = util.resolveGithubRaw(modname)
    if base then
      local code = self:loadCode(tostring(base) .. tostring(file) .. tostring(query))
      _G["__ghrawbase"] = base
      local fn, err = sandbox.loadmoon(code)
      if not (fn) then
        return nil, "error loading '" .. tostring(modname) .. "' with message: " .. tostring(err)
      end
      local rst
      rst, err = sandbox.exec(fn, modname)
      if not (rst) then
        return nil, "error executing '" .. tostring(modname) .. "' with message: " .. tostring(err)
      end
      _G[modname] = rst
    end
  end
  return _G[modname]
end
getSandboxEnv = function(req)
  local env = {
    http = httpc,
    require = require_new,
    util = util,
    crypto = crypto,
    request = req or buildRequest(),
    __ghrawbase = __ghrawbase
  }
  return sandbox.build_env(_G, env, sandbox.whitelist)
end
do
  local _class_0
  local _base_0 = {
    doCheckRemoteFile = function(self, valHolder, req)
      local opts = {
        url = valHolder.url,
        remote_path = self.options.remote_path
      }
      if (valHolder.fileMod ~= nil) then
        opts["last_modified"] = os.date("%c", valHolder.fileMod)
      end
      os.execute("mkdir -p \"" .. valHolder.localPath .. "\"")
      local rsp, err = self.options.codeHandler(opts)
      if (rsp.code == 200) then
        do
          local _with_0 = io.open(valHolder.localFullPath, "w")
          _with_0:write(rsp.body)
          _with_0:close()
        end
        valHolder.fileMod = lfs.attributes(valHolder.localFullPath, "modification")
        valHolder.value = sandbox.loadmoon(rsp.body, valHolder.localFullPath, getSandboxEnv(req))
      elseif (rsp.code == 404) then
        valHolder.value = nil
        return os.remove(valHolder.localFullPath)
      end
    end,
    get = function(self, req)
      if req == nil then
        req = buildRequest()
      end
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
          valHolder.value = sandbox.loadfile_safe(valHolder.localFullPath, getSandboxEnv(req))
          valHolder.lastCheck = os.time()
          self.codeCache:set(url, valHolder)
        else
          valHolder.value = nil
        end
        self:doCheckRemoteFile(valHolder, req)
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
      opts = util.applyDefaults(opts, defOpts)
      if (opts.ttl < 120) then
        opts.ttl = 120
      end
      opts.localBasePath = plpath.abspath(opts.app_path)
      self.codeCache = lru.new(opts.code_cache_size)
      if (opts.ttl < 120) then
        opts.ttl = 120
      end
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
  myUrlHandler = myUrlHandler,
  buildRequest = buildRequest,
  require_new = require_new,
  getSandboxEnv = getSandboxEnv
}
