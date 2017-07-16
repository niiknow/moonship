local http = require("moonship.http")
local azt = require("moonship.aztable")
local util = require("moonship.util")
local from_json, to_json
from_json, to_json = util.from_json, util.to_json
local Storage
do
  local _class_0
  local azure, req, table_name, cache
  local _base_0 = {
    get = function(self, k)
      local realKey = tostring(req.host) .. tostring(k)
      local val = cache:get(realKey)
      if val then
        return val
      end
      local opts = azt.item_retrieve({
        tenant = "a",
        table_name = table_name,
        rk = k,
        pk = req.host
      })
      local res = azt.request(opts, true)
      if not (res.body) then
        return nil, tostring(k) .. " not found"
      end
      local rst = from_json(res.body)
      if (table_name:find("cache")) then
        if (rst.ttlx < os.time()) then
          return nil, tostring(k) .. " not found"
        end
      end
      return rst.v
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
        tenant = "a",
        table_name = table_name,
        rk = k,
        pk = req.host
      }, "MERGE")
      local ttlx = os.time() + ttl
      opts.body = to_json({
        v = v,
        ttlx = ttlx,
        ttl = ttl,
        RowKey = opts.rk,
        PartitionKey = opts.pk
      })
      local res = azt.request(opts, true)
      local realKey = tostring(req.host) .. tostring(k)
      cache:set(realKey, v, 2)
      return res
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self, opts, tableName)
      if tableName == nil then
        tableName = "storage"
      end
      req = opts.plugins.request
      azure = opts.azure
      table_name = tableName
      if ngx then
        cache = ngx.shared["moonship" .. tostring(tableName)]
      end
    end,
    __base = _base_0,
    __name = "Storage"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  local self = _class_0
  azure = { }
  req = { }
  table_name = "storage"
  cache = {
    set = function() end,
    get = function() end
  }
  Storage = _class_0
end
return Storage
