local http = require("moonship.http")
local azt = require("moonship.aztable")
local util = require("moonship.util")
local from_json, to_json
from_json, to_json = util.from_json, util.to_json
local BUFFER_COUNT, FLUSH_INTERVAL, logs, dolog, log
BUFFER_COUNT = 1
FLUSH_INTERVAL = 0.01
logs = { }
dolog = function(logslocal)
  local v = logslocal[1]
  local rk = tostring(v.req.host) .. "$" .. tostring(v.req.path)
  local time = os.time()
  local btime = os.date("%Y%m%d%H%m%S", time)
  local rtime = 99999999999999 - btime
  btime = os.date("%Y-%m-%d %H:%m:%S", time)
  local rand = math.random(10, 10000)
  local pk = tostring(rtime) .. "_" .. tostring(btime) .. "_" .. tostring(rand)
  btime = os.date("%Y%m", time)
  local table_name = "log" .. tostring(btime)
  local opts = azt.item_update({
    tenant = "a",
    table_name = table_name,
    account_key = azure.AccountKey,
    account_name = azure.AccountName,
    rk = rk,
    pk = pk
  }, "MERGE")
  return azt.request(opts)
end
log = function(rsp)
  logs[#logs + 1] = rsp
  local count = #logs
  if (count >= BUFFER_COUNT) then
    local logslocal = logs
    logs = { }
    local delay = math.random(10, 100)
    local ok, err = ngx.timer.at(delay / 1000, dolog, logslocal)
    if err then
      logs = logslocal
    end
  end
end
return {
  log = log
}
