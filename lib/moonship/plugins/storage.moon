-- implement storage with azure

http = require "moonship.http"
aztm = require "moonship.aztablemagic"
request = require "moonship.plugins.request"
util    = require "moonship.util"

import aztable, azauth from aztm
import from_json, to_json from util

get = (k) ->

  opts = opts_cache_get({
    table_name: "storage",
    cache_key: k
  })

  res = http.request(opts)
  return nil, "#{k} not found" unless res.body

  from_json(res.body).value

set = (k, v) ->
  vt = type v

  if (v == "function")
    v = pcall(v)

  vt = type v

  return nil, "value must be string" unless vt == "string"

  opts = opts_cache_set({
    table_name: "storage",
    cache_ttl: ttl or 600,
    cache_key: k,
    cache_value: v
  })

  opts.body = to_json(opts.item)
  res = http.request(opts)

  v

{ :get, :set }
