local config = require("moonship.config")
local codecacher = require("moonship.codecacher")
local util = require("moonship.util")
local sandbox = require("moonship.sandbox")
local httpc = require("moonship.http")
local loadngx, parseGithubRawLua, getSandboxEnv, getRequest, handleResponse, require_new, Engine, EngineOpenResty
loadngx = function(url)
  local res = httpc.request({
    url = url,
    method = "GET",
    capture_url = "/__githubraw"
  })
  if res.status == 200 then
    return res.body
  end
  return "nil"
end
parseGithubRawLua = function(modname)
  local capturePath = "https://raw.githubusercontent.com/"
  if rawget(_G, __ghrawbase) == nil then
    if string.find(modname, "github.com/") then
      local user, repo, branch, pathx, query = string.match(modname, "github%.com/([^/]+)(/[^/]+)/blob(/[^/]+)(/[^?#]*)(.*)")
      local path, file = string.match(pathx, "^(.*/)([^/]*)$")
      local base = string.format("%s%s%s%s%s", capturePath, user, repo, branch, path)
      return base, string.gsub(string.gsub(file, "%.moon$", ""), '%.', "/") .. ".moon", query
    end
  else
    return __ghrawbase, string.gsub(string.gsub(modname, "%.moon$", ""), '%.', "/") .. ".moon", ""
  end
end
getSandboxEnv = function()
  local env = {
    http = httpc,
    require = require_new,
    util = util,
    crypto = crypto,
    request = getRequest(),
    __ghrawbase = __ghrawbase
  }
  return sandbox.build_env(_G or _ENV, env, sandbox.whitelist)
end
getRequest = function()
  ngx.req.read_body()
  local req_wrapper = {
    referer = ngx.var.http_referer or "",
    form = ngx.req.get_post_args(),
    body = ngx.req.get_body_data(),
    query = ngx.req.get_uri_args(),
    querystring = ngx.req.args,
    method = ngx.req.get_method(),
    remote_addr = ngx.var.remote_addr,
    scheme = ngx.var.scheme,
    port = ngx.var.server_port,
    server_addr = ngx.var.server_addr,
    path = ngx.var.uri,
    headers = ngx.req.get_headers()
  }
  return req_wrapper
end
handleResponse = function(first, second)
  local statusCode = 200
  local msg = ""
  local contentType = "text/plain"
  local opts = { }
  local req_method = string.lower(ngx.req.get_method())
  if type(first) == 'number' then
    statusCode = first
    if type(second) == 'string' then
      msg = second
    end
  elseif type(first) == 'string' then
    msg = first
  elseif type(first) == 'table' then
    local func = first[req_method]
    if (type(func) == 'function') then
      local env = getSandboxEnv()
      setfenv(func, env)
      local rsp, err = func()
      second = rsp.headers or { }
      msg = rsp.content
      statusCode = rsp.statuscode or statusCode
    else
      statusCode = 404
    end
  end
  if type(second) == 'table' then
    for k, v in pairs(second) do
      ngx.header[k] = v
      if ('content-type' == string.lower(k)) then
        contentType = nil
      end
    end
  end
  if (contentType ~= nil) then
    ngx.header['Content-Type'] = contentType
  end
  ngx.status = statusCode
  ngx.say(msg)
  return ngx.exit(statusCode)
end
require_new = function(modname)
  local newEnv = getSandboxEnv()
  if newEnv[modname] then
    return newEnv[modname]
  else
    local base, file, query = parseGithubRawLua(modname)
    if base then
      local code = loadngx(base .. file .. query)
      newEnv.__ghrawbase = base
      local fn, err = sandbox.loadstring(code, nil, newEnv)
      return sandbox.exec(fn)
    end
  end
  return nil, "unable to load module [" .. modname .. "]"
end
do
  local _class_0
  local _base_0 = {
    engage = function(self, host, uri)
      local path = util.sanitizePath(string.format("%s/%s", host, uri))
      local fn = self.codeCache:get(path)
      if not (fn) then
        local rsp = sandbox.exec(fn)
        return rsp
      end
    end,
    engageOpenResty = function(self)
      return self:engage(ngx.var.host, ngx.var.uri)
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self, options)
      if options == nil then
        options = { }
      end
      self.options = config.Config:new(options)
      self.codeCache = codecacher.CodeCacher:new(self.options)
    end,
    __base = _base_0,
    __name = "Engine"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  Engine = _class_0
end
do
  local _class_0
  local _parent_0 = Engine
  local _base_0 = {
    engage = function(self, host, uri)
      local path = util.sanitizePath(string.format("%s/%s", ngx.var.host, ngx.var.uri))
      local fn = self.codeCache:get(path)
      if not (fn) then
        local rsp = sandbox.exec(fn)
        return rsp
      end
    end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self, options)
      if options == nil then
        options = { }
      end
      self.options = config.Config:new(options)
      self.codeCache = codecacher.CodeCacher:new(self.options)
    end,
    __base = _base_0,
    __name = "EngineOpenResty",
    __parent = _parent_0
  }, {
    __index = function(cls, name)
      local val = rawget(_base_0, name)
      if val == nil then
        local parent = rawget(cls, "__parent")
        if parent then
          return parent[name]
        end
      else
        return val
      end
    end,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  if _parent_0.__inherited then
    _parent_0.__inherited(_parent_0, _class_0)
  end
  EngineOpenResty = _class_0
end
return {
  Engine = Engine,
  EngineOpenResty = EngineOpenResty
}
