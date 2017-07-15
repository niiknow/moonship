local util = require("moonship.util")
local azureauth = require("moonship.azauth")
local mydate = require("moonship.date")
local string_gsub = string.gsub
local my_max_number = 9007199254740991
local sharedkeylite
sharedkeylite = azureauth.sharedkeylite
local to_json
to_json = util.to_json
local lower
lower = string.lower
local item_list, item_create, item_update, item_retrieve, item_delete, table_opts, opts_name, generate_opts, opts_daily, opts_monthly, opts_yearly
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
  local autho = "SharedKeyLite " .. tostring(opts.account_name) .. ":" .. tostring(opts.sig)
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
  return {
    method = 'GET',
    url = full_path,
    headers = {
      ["Authorization"] = autho,
      ["x-ms-date"] = opts.date,
      ["Accept"] = "application/json;odata=nometadata",
      ["x-ms-version"] = "2016-05-31"
    }
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
  local autho = "SharedKeyLite " .. tostring(opts.account_name) .. ":" .. tostring(opts.sig)
  return {
    method = 'POST',
    url = url,
    data = to_json(item),
    headers = {
      ["Authorization"] = autho,
      ["x-ms-date"] = opts.date,
      ["Accept"] = "application/json;odata=nometadata",
      ["x-ms-version"] = "2016-05-31",
      ["Content-Type"] = "application/json"
    }
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
  local autho = "SharedKeyLite " .. tostring(opts.account_name) .. ":" .. tostring(opts.sig)
  return {
    method = method,
    url = url,
    data = to_json(item),
    headers = {
      ["Authorization"] = autho,
      ["x-ms-date"] = opts.date,
      ["Accept"] = "application/json;odata=nometadata",
      ["x-ms-version"] = "2016-05-31",
      ["Content-Type"] = "application/json"
    }
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
  local autho = "SharedKeyLite " .. tostring(opts.account_name) .. ":" .. tostring(opts.sig)
  return {
    method = "DELETE",
    url = url,
    data = to_json(item),
    headers = {
      ["Authorization"] = autho,
      ["x-ms-date"] = opts.date,
      ["Accept"] = "application/json;odata=nometadata",
      ["x-ms-version"] = "2016-05-31",
      ['If-Match'] = "*"
    }
  }
end
table_opts = function(self, opts)
  opts.table_name = opts:gsub("^/*", "")
  auth.sharedkeylite(opts)
  local url = "https://" .. tostring(opts.account_name) .. ".table.core.windows.net/" .. tostring(opts.table_name)
  local autho = "SharedKeyLite " .. tostring(opts.account_name) .. ":" .. tostring(opts.sig)
  local headers = {
    ["Authorization"] = autho,
    ["x-ms-date"] = opts.date,
    ["Accept"] = "application/json;odata=nometadata",
    ["x-ms-version"] = "2016-05-31"
  }
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
  opts_yearly = opts_yearly
}
