util          = require "moonship.util"
azureauth     = require "moonship.azauth"
mydate        = require "moonship.date"
http          = require "moonship.http"
log           = require "moonship.log"
string_gsub   = string.gsub
my_max_number = 9007199254740991  -- from javascript max safe int

import sharedkeylite from azureauth
import to_json, applyDefaults, trim, table_clone from util
import lower from string

local *

-- generate multitenant opts
opts_name = (opts={ :table_name, :tenant, :env_id, :pk, :prefix }) ->
  if (opts.tenant)
    opts.tenant = lower(opts.tenant)
    opts.table = lower(opts.table_name)
    opts.prefix = "#{opts.tenant}E#{opts.env_id}"
    opts.table_name = "#{opts.prefix}#{opts.table}"

item_headers = (opts, method="GET") ->
  opts_name(opts)
  sharedkeylite(opts)
  hdrs = {
    ["Authorization"]: "SharedKeyLite #{opts.account_name}:#{opts.sig}",
    ["x-ms-date"]: opts.date,
    ["Accept"]: "application/json;odata=nometadata",
    ["x-ms-version"]: "2016-05-31"
  }

  hdrs["Content-Type"] = "application/json" if method == "PUT" or method == "POST" or method == "MERGE"
  hdrs["If-Match"] = "*" if (method == "DELETE")

  hdrs

-- get table header to create or delete table
table_opts = (opts={ :account_name, :account_key, :table_name, :pk, :rk }, method="GET") ->
  url = "https://#{opts.account_name}.table.core.windows.net/#{opts.table_name}"
  headers = item_headers(opts, method)

  -- remove item headers
  headers["If-Match"] = nil if method == "DELETE"

  {
    method: method,
    url: url,
    headers: headers
  }

-- list items
item_list = (opts={ :account_name, :account_key, :table_name }, query={ :filter, :top, :select }) ->
  url = "https://#{opts.account_name}.table.core.windows.net/#{opts.table_name}"
  qs = ""
  qs = "#{qs}&$filter=#{query.filter}" if query.filter
  qs = "#{qs}&$top=#{query.top}" if query.top
  qs = "#{qs}&$select=#{query.select}" if query.select
  qs = trim(qs, "&")
  full_path = url
  full_path = "#{url}?#{qs}" if qs
  headers = item_headers(opts, "GET")

  {
    method: 'GET',
    url: full_path,
    headers: headers
  }

-- create an item
item_create = (opts={ :account_name, :account_key, :table_name }) ->
  url = "https://#{opts.account_name}.table.core.windows.net/#{opts.table_name}"
  headers = item_headers(opts, "POST")

  {
    method: "POST",
    url: url,
    headers: headers
  }

-- update an item, method can be MERGE to upsert
item_update = (opts={ :account_name, :account_key, :table_name, :pk, :rk }, method="PUT") ->
  table = "#{opts.table_name}(PartitionKey='#{opts.pk}',RowKey='#{opts.rk}')"
  opts.table_name = table
  table_opts(opts, method)

-- retrieve an item
item_retrieve = (opts={ :account_name, :account_key, :table_name, :pk, :rk }) ->
  item_list(opts, { filter: "(PartitionKey eq '#{opts.pk}' and RowKey eq '#{opts.rk}')", top: 1 })

-- delete an item
item_delete = (opts={ :account_name, :account_key, :table_name, :pk, :rk }) -> item_update(opts, "DELETE")

generate_opts = (opts={ :table_name }, format="%Y%m%d", ts=os.time()) ->
  newopts = util.table_clone(opts)
  newopts.mt_table = newopts.table_name

  -- trim ending number and replace with dt
  newopts.table_name = string_gsub(newopts.mt_table, "%d+$", "") .. os.date(format, ts)
  newopts

-- generate array of daily opts
opts_daily = (opts={ :table_name, :tenant, :env_id, :pk, :prefix }, days=1, ts=os.time()) ->
  rst = {}
  multiplier = days and 1 or -1
  new_ts = ts
  for i = 1, days
    rst[#rst + 1] = generate_opts(opts, "%Y%m%d", new_ts)
    new_ts = mydate.add_day(new_ts, days)

  rst

-- generate array of monthly opts
opts_monthly = (opts={ :table_name, :tenant, :env_id, :pk, :prefix }, months=1, ts=os.time()) ->
  rst = {}
  multiplier = days and 1 or -1
  new_ts = ts
  for i = 1, days
    rst[#rst + 1] = generate_opts(opts, "%Y%m", new_ts)
    new_ts = mydate.add_month(new_ts, months)

  rst

-- generate array of yearly opts
opts_yearly = (opts={ :table_name, :tenant, :env_id, :pk, :prefix }, years=1, ts=os.time()) ->
  rst = {}
  multiplier = days and 1 or -1
  new_ts = ts
  for i = 1, days
    rst[#rst + 1] = generate_opts(opts, "%Y", new_ts)
    new_ts = mydate.add_year(new_ts, years)

  rst

create_table = (opts) ->
  tableName = opts.table_name
  opts.table_name = "Tables"
  opts.url = ""
  opts.headers = nil
  topts = table_opts(opts, "POST")
  topts.body = to_json({TableName: tableName})
  http.request(topts)

-- make azure storage request
request = (opts, createTableIfNotExists=false) ->
  -- log.error(opts)
  oldOpts = table_clone(opts)
  res = http.request(opts)
  -- log.error(res)

  if (createTableIfNotExists and res and res.body and res.body\find("TableNotFound"))
    -- log.error res
    res = create_table(table_clone(opts))
    return request(oldOpts) if (res and res.code == 201)

  res

{ :item_create, :item_retrieve, :item_update, :item_delete, :item_list, :table_opts
  :opts_name, :opts_daily, :opts_monthly, :opts_yearly, :request
}
