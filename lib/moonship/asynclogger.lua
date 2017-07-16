local http = require("moonship.http")
local azt = require("moonship.aztable")
local util = require("moonship.util")
local log = require("moonship.log")
local from_json, to_json
from_json, to_json = util.from_json, util.to_json
local BUFFER_COUNT, FLUSH_INTERVAL, dolog, AsyncLogger
BUFFER_COUNT = 1
FLUSH_INTERVAL = 0.01
dolog = function(self, v)
  local req = v.req
  local logs = req.logs
  v.req = nil
  req.logs = nil
  local rk = (tostring(req.host) .. " " .. tostring(req.path)):gsub("/", "$")
  local time = os.time()
  local btime = os.date("%Y%m%d%H%m%S", time)
  local rtime = 99999999999999 - btime
  btime = os.date("%Y-%m-%d %H:%m:%S", time)
  local rand = math.random(10, 1000)
  local pk = tostring(rtime) .. "_" .. tostring(btime) .. " " .. tostring(rand)
  btime = os.date("%Y%m", time)
  local table_name = "log" .. tostring(btime)
  local opts = azt.item_create({
    tenant = "a",
    table_name = table_name,
    rk = rk,
    pk = pk
  }, "MERGE")
  v.req = nil
  v.RowKey = rk
  v.PartitionKey = pk
  v.host = req.host
  v.path = req.path
  v.start = req.start
  v["end"] = req["end"]
  v.time = v["end"] - v.start
  v.req = to_json(req)
  v.logs = to_json(logs)
  opts.body = to_json(v)
  return azt.request(opts, true)
end
do
  local _class_0
  local _base_0 = {
    dolog = dolog,
    log = function(self, rsp)
      if (ngx) then
        local delay = math.random(10, 100)
        local ok, err = ngx.timer.at(delay / 1000, dolog, self, rsp)
      end
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function() end,
    __base = _base_0,
    __name = "AsyncLogger"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  AsyncLogger = _class_0
end
return AsyncLogger
