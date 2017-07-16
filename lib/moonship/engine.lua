local config = require("moonship.config")
local codecacher = require("moonship.codecacher")
local util = require("moonship.util")
local log = require("moonship.log")
local Storage = require("moonship.plugins.storage")
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
      rst.headers = rst.headers or { }
      rst.headers["Content-Type"] = rst.headers["Content-Type"] or "text/plain"
      return rst
    end,
    engage = function(self, req)
      local opts = self.options:get()
      if req then
        opts.plugins["request"] = req
      end
      req = opts.plugins["request"]
      if not (opts.plugins["storage"]) then
        opts.plugins["storage"] = Storage(opts, "storage")
      end
      if not (opts.plugins["cache"]) then
        opts.plugins["cache"] = Storage(opts, "cache")
      end
      local rst, err = self.codeCache:get(opts)
      if err then
        return {
          req = req,
          error = err,
          code = 500,
          status = "500 Engine.engage error",
          headers = { }
        }
      end
      if not (rst) then
        return {
          req = req,
          code = 404,
          headers = { }
        }
      end
      self:handleResponse(rst)
      rst.req = req
      return rst
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self, opts)
      local options = util.applyDefaults(opts, { })
      if (options.useS3) then
        options.aws = {
          aws_access_key_id = options.aws_access_key_id,
          aws_secret_access_key = options.aws_secret_access_key,
          aws_s3_code_path = options.aws_s3_code_path
        }
      end
      self.options = config(options)
      self.codeCache = codecacher.CodeCacher(self.options:get())
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
return Engine
