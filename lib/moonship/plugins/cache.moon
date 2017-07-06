-- implement cache with azure

http = require "moonship.http"
aztm = require "moonship.aztablemagic"
request = require "moonship.plugins.request"
util    = require "moonship.util"

import aztable, azauth from aztm
import from_json, to_json from util

get = (k) ->

  opts = opts_cache_get({
    table_name: "cache",
    cache_key: k
  })

  res = http.request(opts)
  return nil unless res.body

  from_json(res.body).value

set = (k, v, ttl=600) ->
  vt = type v

  if (v == "function")
    v = pcall(v)

  vt = type v

  return nil unless vt == "string"

  opts = opts_cache_set({
    table_name: "cache",
    cache_ttl: ttl or 600,
    cache_key: k,
    cache_value: v
  })

  opts.body = to_json(opts.item)
  res = http.request(opts)

  v

{ :get, :set }
