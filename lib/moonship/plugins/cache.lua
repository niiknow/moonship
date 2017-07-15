local http = require("moonship.http")
local azt = require("moonship.aztable")
local request = require("moonship.plugins.request")
local util = require("moonship.util")
local from_json, to_json
from_json, to_json = util.from_json, util.to_json
local Cache
do
  local _class_0
  local _base_0 = {
    get = function(self, k)
      local opts = azt.item_retrieve({
        table_name = "storage",
        rk = k,
        pk = ''
      })
      local res = http.request(opts)
      if not (res.body) then
        return nil, tostring(k) .. " not found"
      end
      return from_json(res.body).v
    end,
    set = function(self, k, v, ttl)
      if ttl == nil then
        ttl = 600
      end
      local vt = type(v)
      if not (vt == "string") then
        return nil, "value must be string"
      end
      local opts = azt.item_update({
        table_name = "storage",
        cache_key = k
      }, v, "MERGE")
      opts.body = to_json(opts.item)
      local res = http.request(opts)
      return v
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function() end,
    __base = _base_0,
    __name = "Cache"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  Cache = _class_0
end
return Cache
