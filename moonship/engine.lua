local config = require("moonship.config")
local codecacher = require("moonship.codecacher")
local util = require("moonship.util")
local Engine
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
      local rst = self.codeCache.get(path)
      if not (rst and rst.value) then
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
      if (options.useS3) then
        options.aws = {
          aws_access_key_id = options.aws_access_key_id,
          aws_secret_access_key = options.aws_secret_access_key,
          aws_s3_code_path = options.aws_s3_code_path
        }
      end
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
