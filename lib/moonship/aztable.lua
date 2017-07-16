local util = require("moonship.util")
local azureauth = require("moonship.azauth")
local mydate = require("moonship.date")
local http = require("moonship.http")
local log = require("moonship.log")
local string_gsub = string.gsub
local my_max_number = 9007199254740991
local sharedkeylite
sharedkeylite = azureauth.sharedkeylite
local to_json, applyDefaults
to_json, applyDefaults = util.to_json, util.applyDefaults
local lower
lower = string.lower
local get_headers, item_list, item_create, item_update, item_retrieve, item_delete, table_opts, opts_name, generate_opts, opts_daily, opts_monthly, opts_yearly, createTableThenExecute, request
get_headers = function(headers)
  return applyDefaults(headers, {
    ["Accept"] = "application/json;odata=nometadata",
    ["x-ms-version"] = "2016-05-31"
  })
end
item_list = function(opts, query)
  if opts == nil then
    opts = {
      account_name = account_name,
      account_key = account_key,
      table_name = table_name
    }
  end
  if query == nil then
    query = {
      filter = filter,
      top = top,
      select = select
    }
  end
  sharedkeylite(opts)
  local url = "https://" .. tostring(opts.account_name) .. ".table.core.windows.net/" .. tostring(opts.table_name)
  local Authorization = "SharedKeyLite " .. tostring(opts.account_name) .. ":" .. tostring(opts.sig)
  local qs = ""
  if query.filter then
    qs = tostring(qs) .. "&$filter=%{query.filter}"
  end
  if query.top then
    qs = tostring(qs) .. "&$top=%{query.top}"
  end
  if query.select then
    qs = tostring(qs) .. "&$select=%{query.select}"
  end
  local full_path = tostring(url) .. "?" .. tostring(qs)
  local headers = get_headers({
    Authorization = Authorization,
    ["x-ms-date"] = opts.date
  })
  return {
    method = 'GET',
    url = full_path,
    headers = headers
  }
end
item_create = function(opts, item)
  if opts == nil then
    opts = {
      account_name = account_name,
      account_key = account_key,
      table_name = table_name
    }
  end
  sharedkeylite(opts)
  local url = "https://" .. tostring(opts.account_name) .. ".table.core.windows.net/" .. tostring(opts.table_name)
  local Authorization = "SharedKeyLite " .. tostring(opts.account_name) .. ":" .. tostring(opts.sig)
  local headers = get_headers({
    Authorization = Authorization,
    ["x-ms-date"] = opts.date,
    ["Content-Type"] = "application/json"
  })
  return {
    method = 'POST',
    url = url,
    data = to_json(item),
    headers = headers
  }
end
item_update = function(opts, item, method)
  if opts == nil then
    opts = {
      account_name = account_name,
      account_key = account_key,
      table_name = table_name,
      pk = pk,
      rk = rk
    }
  end
  if method == nil then
    method = "PUT"
  end
  local table = tostring(opts.table_name) .. "(PartitionKey='" .. tostring(item.pk) .. "',RowKey='" .. tostring(item.rk) .. "')"
  opts.table_name = table
  sharedkeylite(opts)
  local url = "https://" .. tostring(opts.account_name) .. ".table.core.windows.net/" .. tostring(opts.table_name)
  local Authorization = "SharedKeyLite " .. tostring(opts.account_name) .. ":" .. tostring(opts.sig)
  local headers = get_headers({
    Authorization = Authorization,
    ["x-ms-date"] = opts.date,
    ["Content-Type"] = "application/json"
  })
  return {
    method = method,
    url = url,
    data = to_json(item),
    headers = headers
  }
end
item_retrieve = function(opts)
  if opts == nil then
    opts = {
      account_name = account_name,
      account_key = account_key,
      table_name = table_name,
      pk = pk,
      rk = rk
    }
  end
  return item_list(opts, {
    filter = "(PartitionKey eq '" .. tostring(opts.pk) .. "' and RowKey eq '" .. tostring(opts.rk) .. "')",
    top = 1
  })
end
item_delete = function(opts)
  if opts == nil then
    opts = {
      account_name = account_name,
      account_key = account_key,
      table_name = table_name,
      pk = pk,
      rk = rk
    }
  end
  local table = tostring(opts.table_name) .. "(PartitionKey='" .. tostring(item.pk) .. "',RowKey='" .. tostring(item.rk) .. "')"
  opts.table_name = table
  sharedkeylite(opts)
  local url = "https://" .. tostring(opts.account_name) .. ".table.core.windows.net/" .. tostring(opts.table_name)
  local Authorization = "SharedKeyLite " .. tostring(opts.account_name) .. ":" .. tostring(opts.sig)
  local headers = get_headers({
    Authorization = Authorization,
    ["x-ms-date"] = opts.date,
    ["If-Match"] = "*"
  })
  return {
    method = "DELETE",
    url = url,
    data = to_json(item),
    headers = headers
  }
end
table_opts = function(self, opts)
  opts.table_name = opts:gsub("^/*", "")
  auth.sharedkeylite(opts)
  local url = "https://" .. tostring(opts.account_name) .. ".table.core.windows.net/" .. tostring(opts.table_name)
  local Authorization = "SharedKeyLite " .. tostring(opts.account_name) .. ":" .. tostring(opts.sig)
  local headers = get_headers({
    Authorization = Authorization,
    ["x-ms-date"] = opts.date
  })
  if not ((opts.method == "GET" or opts.method == "DELETE")) then
    headers["Content-Type"] = "application/json"
  end
  return {
    method = opts.method,
    url = url,
    headers = headers
  }
end
opts_name = function(opts)
  if opts == nil then
    opts = {
      table_name = table_name,
      tenant = tenant,
      env_id = env_id,
      pk = pk,
      prefix = prefix
    }
  end
  opts.pk = opts.pk or "1default"
  opts.tenant = lower(opts.tenant or "a")
  opts.table = lower(opts.table_name)
  opts.prefix = tostring(opts.tenant) .. "E" .. tostring(opts.env_id)
  opts.table_name = tostring(opts.prefix) .. tostring(opts.table)
end
generate_opts = function(opts, format, ts)
  if opts == nil then
    opts = {
      table_name = table_name
    }
  end
  if format == nil then
    format = "%Y%m%d"
  end
  if ts == nil then
    ts = os.time()
  end
  local newopts = util.table_clone(opts)
  newopts.mt_table = newopts.table_name
  newopts.table_name = string_gsub(newopts.mt_table, "%d+$", "") .. os.date(format, ts)
  return newopts
end
opts_daily = function(opts, days, ts)
  if opts == nil then
    opts = {
      table_name = table_name,
      tenant = tenant,
      env_id = env_id,
      pk = pk,
      prefix = prefix
    }
  end
  if days == nil then
    days = 1
  end
  if ts == nil then
    ts = os.time()
  end
  local rst = { }
  local multiplier = days and 1 or -1
  local new_ts = ts
  for i = 1, days do
    rst[#rst + 1] = generate_opts(opts, "%Y%m%d", new_ts)
    new_ts = mydate.add_day(new_ts, days)
  end
  return rst
end
opts_monthly = function(opts, months, ts)
  if opts == nil then
    opts = {
      table_name = table_name,
      tenant = tenant,
      env_id = env_id,
      pk = pk,
      prefix = prefix
    }
  end
  if months == nil then
    months = 1
  end
  if ts == nil then
    ts = os.time()
  end
  local rst = { }
  local multiplier = days and 1 or -1
  local new_ts = ts
  for i = 1, days do
    rst[#rst + 1] = generate_opts(opts, "%Y%m", new_ts)
    new_ts = mydate.add_month(new_ts, months)
  end
  return rst
end
opts_yearly = function(opts, years, ts)
  if opts == nil then
    opts = {
      table_name = table_name,
      tenant = tenant,
      env_id = env_id,
      pk = pk,
      prefix = prefix
    }
  end
  if years == nil then
    years = 1
  end
  if ts == nil then
    ts = os.time()
  end
  local rst = { }
  local multiplier = days and 1 or -1
  local new_ts = ts
  for i = 1, days do
    rst[#rst + 1] = generate_opts(opts, "%Y", new_ts)
    new_ts = mydate.add_year(new_ts, years)
  end
  return rst
end
createTableThenExecute = function(opts, fn)
  local tableOpts = table_clone(opts)
  local newTableName = table_opts.table_name
  tableOpts.table_name = "Tables"
  tableOpts.body = to_json({
    TableName = newTableName
  })
  tableOpts.method = "POST"
  local topts = table_opts(tableOpts)
  local res = http.request(topts)
  log.error(res)
  if (res and res.code == 200) then
    return fn(opts)
  end
  return res
end
request = function(opts, createTableIfNotExists)
  if createTableIfNotExists == nil then
    createTableIfNotExists = false
  end
  local res = http.request(opts)
  if (createTableIfNotExists and res and res.body and res.body:find("not exist")) then
    log.error(res)
    return createTableThenExecute(opts, request)
  end
  return res
end
return {
  item_create = item_create,
  item_retrieve = item_retrieve,
  item_update = item_update,
  item_delete = item_delete,
  item_list = item_list,
  table_opts = table_opts,
  opts_name = opts_name,
  opts_daily = opts_daily,
  opts_monthly = opts_monthly,
  opts_yearly = opts_yearly,
  request = request
}
