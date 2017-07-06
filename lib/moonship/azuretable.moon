util          = require "moonship.util"
azureauth     = require "moonship.azureauth"
import sharedkeylite from azureauth
import to_json from util

-- list items
item_list = (opts={ :account_name, :account_key, :table_name }, query={ :filter, :top, :select }) ->
  sharedkeylite(opts)
  url = "https://#{opts.account_name}.table.core.windows.net/#{opts.table_name}"
  autho = "SharedKeyLite #{opts.account_name}:#{opts.sig}"
  qs = ""
  qs = "#{qs}&$filter=%{query.filter}" if query.filter
  qs = "#{qs}&$top=%{query.top}" if query.top
  qs = "#{qs}&$select=%{query.select}" if query.select
  full_path = "#{url}?#{qs}"

  {
    method: 'GET',
    url: full_path,
    headers: {
      ["Authorization"]: autho,
      ["x-ms-date"]: opts.date,
      ["Accept"]: "application/json;odata=nometadata",
      ["x-ms-version"]: "2016-05-31"
    }
  }

-- create an item
item_create = (opts={ :account_name, :account_key, :table_name }, item) ->
  sharedkeylite(opts)
  url = "https://#{opts.account_name}.table.core.windows.net/#{opts.table_name}"
  autho = "SharedKeyLite #{opts.account_name}:#{opts.sig}"

  {
    method: 'POST',
    url: url,
    data: to_json(item),
    headers: {
      ["Authorization"]: autho,
      ["x-ms-date"]: opts.date,
      ["Accept"]: "application/json;odata=nometadata",
      ["x-ms-version"]: "2016-05-31",
      ["Content-Type"]: "application/json"
    }
  }

-- update an item, method can be MERGE to upsert
item_update = (opts={ :account_name, :account_key, :table_name, :PartitionKey, :RowKey }, item, method="PUT") ->
  table = "#{opts.table_name}(PartitionKey='#{item.PartitionKey}',RowKey='#{item.RowKey}')"
  opts.table_name = table
  sharedkeylite(opts)
  url = "https://#{opts.account_name}.table.core.windows.net/#{opts.table_name}"
  autho = "SharedKeyLite #{opts.account_name}:#{opts.sig}"

  {
    method: method,
    url: url,
    data: to_json(item),
    headers: {
      ["Authorization"]: autho,
      ["x-ms-date"]: opts.date,
      ["Accept"]: "application/json;odata=nometadata",
      ["x-ms-version"]: "2016-05-31",
      ["Content-Type"]: "application/json"
    }
  }

-- retrieve an item
item_retrieve = (opts={ :account_name, :account_key, :table_name, :PartitionKey, :RowKey }) ->
  item_list(opts, { filter: "(PartitionKey eq '#{opts.PartitionKey}' and RowKey eq '#{opts.RowKey}')", top: 1 })

-- delete an item
item_delete = (opts={ :account_name, :account_key, :table_name, :PartitionKey, :RowKey }) ->
  table = "#{opts.table_name}(PartitionKey='#{item.PartitionKey}',RowKey='#{item.RowKey}')"
  opts.table_name = table
  sharedkeylite(opts)
  url = "https://#{opts.account_name}.table.core.windows.net/#{opts.table_name}"
  autho = "SharedKeyLite #{opts.account_name}:#{opts.sig}"

  {
    method: "DELETE",
    url: url,
    data: to_json(item),
    headers: {
      ["Authorization"]: autho,
      ["x-ms-date"]: opts.date,
      ["Accept"]: "application/json;odata=nometadata",
      ["x-ms-version"]: "2016-05-31",
      ['If-Match']: "*"
    }
  }

-- get table header to create or delete table
table_opts: (opts) =>
  opts.table_name = opts\gsub("^/*", "")
  auth.sharedkeylite(opts)
  url = "https://#{opts.account_name}.table.core.windows.net/#{opts.table_name}"
  autho = "SharedKeyLite #{opts.account_name}:#{opts.sig}"
  headers = {
    ["Authorization"]: autho,
    ["x-ms-date"]: opts.date,
    ["Accept"]: "application/json;odata=nometadata",
    ["x-ms-version"]: "2016-05-31"
  }

  headers["Content-Type"] = "application/json" unless (opts.method == "GET" or opts.method == "DELETE")

  {
    method: opts.method,
    url: url,
    headers: headers
  }

{
  :item_create,
  :item_retrieve,
  :item_update,
  :item_delete,
  :item_list,
  :table_opts
}
