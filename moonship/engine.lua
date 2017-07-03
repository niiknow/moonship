local config = require("moonship.config")
local codecacher = require("moonship.codecacher")
local util = require("moonship.util")
local sandbox = require("moonship.sandbox")
local httpc = require("moonship.http")
local loadCode, buildRequest, require_new, Engine
loadCode = function(url)
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
buildRequest = function()
  if ngx then
    ngx.req.read_body()
    local req_wrapper = {
      body = ngx.req.get_body_data(),
      form = ngx.req.get_post_args(),
      headers = ngx.req.get_headers(),
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
      local fn, err = sandbox.loadstring(code, nil, _G)
      if not (fn) then
        return nil, "error loading '" .. tostring(modname) .. "' with message: " .. tostring(err)
      end
      local rst
      rst, err = sandbox.exec(fn)
      if not (rst) then
        return nil, "error executing '" .. tostring(modname) .. "' with message: " .. tostring(err)
      end
      _G[modname] = rst
    end
  end
  return _G[modname]
end
local _ = {
  getSandboxEnv = function()
    local env = {
      http = httpc,
      require = require_new,
      util = util,
      crypto = crypto,
      request = buildRequest(),
      __ghrawbase = __ghrawbase
    }
    return sandbox.build_env(_G, env, sandbox.whitelist)
  end
}
do
  local _class_0
  local _base_0 = {
    handleResponse = function(self, rst)
      if type(rst) ~= 'table' then
        return {
          body = rst,
          code = 500,
          status = "500 unexpected response",
          headers = {
            ['Content-Type'] = "text/plain"
          }
        }
      end
      rst.code = rst.code or 200
      rst.headers["Content-Type"] = rst.headers["Content-Type"] or "text/plain"
      return rst
    end,
    engage = function(self, host, uri)
      if host == nil then
        host = (ngx and ngx.var.host)
      end
      if uri == nil then
        uri = (ngx and ngx.var.uri)
      end
      local path = util.sanitizePath(string.format("%s/%s", host, uri))
      local rst, err = self.codeAdaptor.run(path)
      if not (err) then
        return self:handleResponse(rst)
      end
      return {
        error = err,
        code = 500,
        status = "500 Engine.engage error"
      }
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
return {
  Engine = Engine
}
