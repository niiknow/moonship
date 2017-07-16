-- implement storage with azure

http    = require "moonship.http"
azt     = require "moonship.aztable"
util    = require "moonship.util"

import from_json, to_json from util

class Storage
  azure = {}
  req = {}
  table_name = "storage"
  new: (opts, tableName="storage") =>
    req = opts.plugins.request
    azure = opts.azure
    table_name = tableName

  get: (k) =>

    opts = azt.item_retrieve({
      table_name: table_name,
      account_key: azure.AccountKey,
      account_name: azure.AccountName,
      rk: k,
      pk: req.host
    })

    res = azt.request(opts, true)
    return nil, "#{k} not found" unless res.body

    rst = from_json(res.body)
    if (table_name\find("cache"))
      return nil, "#{k} not found" if (rst.ttlx <= os.time())

    rst.v

  set: (k, v, ttl=600) =>
    vt = type v

    return nil, "value must be string" unless vt == "string"

    opts = azt.item_update({
      table_name: table_name,
      account_key: azure.AccountKey,
      account_name: azure.AccountName,
      rk: k,
      pk: req.host
    }, "MERGE")
    ttlx = os.time() + ttl

    opts.body = to_json({:v, :ttlx, RowKey: opts.rk, PartitionKey: opts.pk})
    res = azt.request(opts, true)

    -- return response
    res


Storage
