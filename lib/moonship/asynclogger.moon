-- implement async or bulk logging

http    = require "moonship.http"
azt     = require "moonship.aztable"
util    = require "moonship.util"

import from_json, to_json from util

local *

-- number of items when flush
  -- currently set to 1 until we get azure bulk to work
BUFFER_COUNT = 1

-- time between flush
  -- currently set to very low until we get azure bulk to work
FLUSH_INTERVAL = 0.01

dolog = (v) =>
  rk = "#{v.req.host}$#{v.req.path}"
  time = os.time()
  btime = os.date("%Y%m%d%H%m%S",time)
  rtime = 99999999999999 - btime
  btime = os.date("%Y-%m-%d %H:%m:%S", time)
  rand = math.random(10, 1000)
  pk = "#{rtime}_#{btime}_#{rand}"
  btime = os.date("%Y%m", time)
  table_name = "log#{btime}"

  opts = azt.item_update({
    tenant: "a",
    table_name: table_name,
    rk: rk,
    pk: pk
  }, "MERGE")

  res = azt.request(opts)

class AsyncLogger
  log: (rsp) =>
    if (ngx)
      delay = math.random(10, 100)
      ok, err = ngx.timer.at(delay / 1000, dolog, self, rsp)

AsyncLogger
