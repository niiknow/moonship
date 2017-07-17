-- implement async or bulk logging

http    = require "moonship.http"
azt     = require "moonship.aztable"
util    = require "moonship.util"
log     = require "moonship.log"

import from_json, to_json, table_clone from util

local *

-- number of items when flush
  -- currently set to 1 until we get azure bulk to work
BUFFER_COUNT = 1

-- time between flush
  -- currently set to very low until we get azure bulk to work
FLUSH_INTERVAL = 0.01

dolog = (rsp) =>
  v = {}
  req = rsp.req
  logs = req.logs
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
  })

  v.RowKey = rk
  v.PartitionKey = pk
  v.host = req.host
  v.path = req.path
  v.time = req.end - req.start
  v.req = to_json(req)
  v.err = tostring(rsp.err)
  v.code = rsp.code
  v.status = rsp.status
  v.headers = to_json(rsp.headers)
  v.body = rsp.body

  if (#logs > 0)
    v.logs = to_json(logs)

  opts.body = to_json(v)
  opts.useSocket = true
  res = azt.request(opts, true)
  res

class AsyncLogger
  dolog: dolog
  log: (rsp) =>
    if (ngx)
      myrsp = table_clone(rsp)
      delay = math.random(10, 100)
      ok, err = ngx.timer.at(delay / 1000, dolog, self, myrsp)

AsyncLogger
