local util = require("moonship.util")
local azureauth = require("moonship.azauth")
local sharedkeylite
sharedkeylite = azureauth.sharedkeylite
local to_json
to_json = util.to_json
local item_list
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
local item_create
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
local item_update
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
local item_retrieve
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
local item_delete
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
local _ = {
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
}
return {
  item_create = item_create,
  item_retrieve = item_retrieve,
  item_update = item_update,
  item_delete = item_delete,
  item_list = item_list,
  table_opts = table_opts
}
