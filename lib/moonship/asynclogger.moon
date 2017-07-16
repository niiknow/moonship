-- implement async or bulk logging

http    = require "moonship.http"
azt     = require "moonship.aztable"
util    = require "moonship.util"
log     = require "moonship.log"

import from_json, to_json from util

local *

-- number of items when flush
  -- currently set to 1 until we get azure bulk to work
BUFFER_COUNT = 1

-- time between flush
  -- currently set to very low until we get azure bulk to work
FLUSH_INTERVAL = 0.01

dolog = (v) =>
  req = v.req
  logs = req.logs
  v.req = nil
  req.logs= nil

  -- replace illegal forward slash char
  rk = "#{req.host} #{req.path}"\gsub("/", "$")
  time = os.time()
  btime = os.date("%Y%m%d%H%m%S",time)
  rtime = 99999999999999 - btime
  btime = os.date("%Y-%m-%d %H:%m:%S", time)
  rand = math.random(10, 1000)
  pk = "#{rtime}_#{btime} #{rand}"
  btime = os.date("%Y%m", time)
  table_name = "log#{btime}"

  opts = azt.item_create({
    tenant: "a",
    table_name: table_name,
    rk: rk,
    pk: pk
  }, "MERGE")

  v.req = nil
  v.RowKey = rk
  v.PartitionKey = pk
  v.host = req.host
  v.path = req.path
  v.start = req.start
  v.end = req.end
  v.time = v.end - v.start
  v.req = to_json(req)
  v.logs = to_json(logs)

  opts.body = to_json(v)
  -- log.error opts
  azt.request(opts, true)

class AsyncLogger
  dolog: dolog
  log: (rsp) =>
    if (ngx)
      delay = math.random(10, 100)
      ok, err = ngx.timer.at(delay / 1000, dolog, self, rsp)

AsyncLogger
