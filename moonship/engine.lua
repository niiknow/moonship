local config = require("moonship.config")
local codecacher = require("moonship.codecacher")
local util = require("moonship.util")
local sandbox = require("moonship.sandbox")
local Engine
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
return {
  Engine = Engine
}
