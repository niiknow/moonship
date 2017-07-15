-- implement storage with azure

http    = require "moonship.http"
azt     = require "moonship.aztable"
request = require "moonship.plugins.request"
util    = require "moonship.util"

import from_json, to_json from util

class Storage
  get: (k) =>

    opts = azt.item_retrieve({
      table_name: "storage",
      rk: k,
      pk: ''
    })

    res = http.request(opts)
    return nil, "#{k} not found" unless res.body

    from_json(res.body).v

  set: (k, v) =>
    vt = type v

    return nil, "value must be string" unless vt == "string"

    opts = azt.item_update({
      table_name: "storage",
      cache_key: k
    }, v, "MERGE")

    opts.body = to_json(opts.item)
    res = http.request(opts)

    v

Storage
